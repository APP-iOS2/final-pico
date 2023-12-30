//
//  ChattingDetailViewController.swift
//  Pico
//
//  Created by 양성혜 on 2023/12/16.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ChattingDetailViewController: UIViewController {
    
    private let sendViewModel = ChattingViewModel()
    private let disposeBag = DisposeBag()
    private let refreshControl = UIRefreshControl()
    private let refreshPublisher = PublishSubject<Void>()
    private let loadDataPublsher = PublishSubject<Void>()
    private let checkReceiveEmptyPublisher = PublishSubject<Void>()
    private let footerView = FooterView()
    private var isRefresh = false
    
    var opponentId: String = ""
    var opponentName: String = ""
    var roomId: String = ""
    
    var chattingsCount: Int = 0
    var bottomConstraint = NSLayoutConstraint()
    
    private let chattingView = UITableView()
    
    private let sendStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        return stackView
    }()
    
    private let chatTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "채팅을 입력해주세요"
        textField.font = UIFont.picoDescriptionFont
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.picoFontGray.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 12.0, height: 0.0))
        textField.leftViewMode = .always
        return textField
    }()
    
    private let sendButton: UIButton = {
        let button = CommonButton(type: .custom)
        button.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        button.setPreferredSymbolConfiguration(.init(pointSize: 25, weight: .regular, scale: .default), forImageIn: .normal)
        button.backgroundColor = .clear
        button.tintColor = .picoBlue
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configViewController()
        view.tappedDismissKeyboard()
        addViews()
        makeConstraints()
        configTableView()
        configRefresh()
        configSendButton()
        loadDataPublsher.onNext(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configChatFieldView()
        chattingView.reloadData()
        refreshPublisher.onNext(())
    }

    private func addViews() {
        sendStack.addArrangedSubview([chatTextField, sendButton])
        view.addSubview([chattingView, sendStack])
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        sendButton.snp.makeConstraints { make in
            make.width.equalTo(50)
        }
        
        sendStack.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(20)
            make.trailing.equalTo(safeArea).offset(-20)
            make.height.equalTo(40)
        }
        
        chattingView.snp.makeConstraints { make in
            make.top.leading.equalTo(safeArea)
            make.trailing.equalTo(safeArea)
            make.bottom.equalTo(sendStack.snp.top).offset(-10)
        }
        
        bottomConstraint = sendStack.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -10)
        view.addConstraint(bottomConstraint)
    }
    
    func configData(room: Room.RoomInfo) {
        FirestoreService.shared.searchDocumentWithEqualField(collectionId: .users, field: "id", compareWith: room.opponentId, dataType: User.self) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let user):
                if !user.isEmpty {
                    guard let userData = user[safe: 0] else { break }
                    opponentName = userData.nickName
                    navigationItem.title = opponentName
                }
            case .failure(let err):
                print(err)
            }
        }
        roomId = room.id
        sendViewModel.roomId = roomId
        opponentId = room.opponentId
    }
    
    private func configViewController() {
        view.configBackgroundColor()
        navigationItem.titleView?.tintColor = .picoAlphaBlue
        tabBarController?.tabBar.isHidden = true
    }
    
    private func configChatFieldView() {
        chatTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func configTableView() {
        chattingView.register(cell: ChattingReceiveListTableViewCell.self)
        chattingView.register(cell: ChattingSendListTableViewCell.self)
        footerView.frame = CGRect(x: 0, y: 0, width: chattingView.bounds.size.width, height: 80)
        if #available(iOS 15.0, *) {
            chattingView.tableHeaderView = UIView()
        }
        chattingView.separatorStyle = .none
        chattingView.keyboardDismissMode = .onDrag
        chattingView.dataSource = self
        chattingView.delegate = self
    }
    
    private func configRefresh() {
        refreshControl.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        refreshControl.tintColor = .picoBlue
        refreshControl.backgroundColor = .picoGray
        chattingView.refreshControl = refreshControl
    }
    
    private func configSendButton() {
        sendButton.rx.tap
            .bind { [weak self] _ in
                guard let self = self  else { return }
                self.sendButton.tappedAnimation()
                if let text = self.chatTextField.text {
                    // sender: 로그인한 사람, recevie 받는 사람
                    let chatting: Chatting.ChattingInfo = Chatting.ChattingInfo(roomId: roomId, sendUserId: UserDefaultsManager.shared.getUserData().userId, receiveUserId: opponentId, message: text, sendedDate: Date().timeIntervalSince1970, isReading: true, messageType: .send)
                    
                    self.sendViewModel.updateChattingData(chattingData: chatting)
                    
                    chatTextField.text = ""
                    chattingView.reloadData()
                    refreshPublisher.onNext(())
                    
                    self.sendViewModel.updateRoomData(chattingData: chatting)
                    
                    if self.chattingsCount > 0 {
                        self.chattingView.scrollToRow(at: IndexPath(item: self.chattingsCount - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
    @objc func refreshTable(refresh: UIRefreshControl) {
        isRefresh = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            refreshPublisher.onNext(())
            refresh.endRefreshing()
            isRefresh = false
            if self.chattingsCount > 0 {
                self.chattingView.scrollToRow(at: IndexPath(item: self.chattingsCount - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
            }
            print("여기는 언제?")
        }
    }
}
// MARK: - TableView
extension ChattingDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sender = sendViewModel.sendChattingList.count
        let receive = sendViewModel.receiveChattingList.count
        chattingsCount = sender + receive
        print("sender: \(sender),receive: \(receive)")
        return chattingsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var chattingArray = sendViewModel.sendChattingList + sendViewModel.receiveChattingList
        chattingArray.sort(by: {$0.sendedDate < $1.sendedDate})
        
        guard let item = chattingArray[safe: indexPath.row] else { return UITableViewCell() }
        switch item.messageType {
        case .receive:
            let receiveCell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: ChattingReceiveListTableViewCell.self)
            receiveCell.config(chatting: item)
            receiveCell.selectionStyle = .none
            receiveCell.backgroundColor = .clear
            return receiveCell
        case .send:
            let sendCell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: ChattingSendListTableViewCell.self)
            sendCell.config(chatting: item)
            sendCell.selectionStyle = .none
            sendCell.backgroundColor = .clear
            return sendCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var chattingArray = sendViewModel.sendChattingList + sendViewModel.receiveChattingList
        chattingArray.sort(by: {$0.sendedDate < $1.sendedDate})
        
        if let item = chattingArray[safe: indexPath.row] {
            switch item.messageType {
            case .receive:
                return 70
            case .send:
                return 50
            }
        }
        return 70
    }
}
// MARK: - Bind
extension ChattingDetailViewController {
    private func bind() {
        let sendInput = ChattingViewModel.Input(listLoad: loadDataPublsher, refresh: refreshPublisher)
        let sendOutput = sendViewModel.transform(input: sendInput)
        
        sendOutput.reloadChattingTableView
            .withUnretained(self)
            .subscribe { viewController, _ in
                viewController.chattingView.reloadData()
            }
            .disposed(by: disposeBag)
    }
}

extension ChattingDetailViewController: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatTextField.resignFirstResponder()
        return false
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.bottomConstraint.constant = -keyboardRectangle.height
        }
        
        UIView.animate(withDuration: 0) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            if self.chattingsCount > 0 {
                self.chattingView.scrollToRow(at: IndexPath(item: self.chattingsCount - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        self.bottomConstraint.constant = -10
        view.addConstraint(self.bottomConstraint)
        self.view.layoutIfNeeded()
    }
}

// Text가 화면의 2/3 이상이면 잘라서 보이도록 하기 --> 물어보기 // uikit 라벨 최대 trailing 하는 방법 찾아서 넣기
// 자동으로 reload 데이터 할 수 있도록 찾아보기 --> 번쩍쓰 생김 이유 모르겠음.. [다른 데이터 접근 시 그런다고 함]
// 토글해야 맨 아래로 내려감 --> 시작과 동시에 할 수 있는 방법 찾기
