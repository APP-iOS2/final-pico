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
    
    private let viewModel = ChattingViewModel()
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
        addViews()
        makeConstraints()
        configTableView()
        configRefresh()
        configSendButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configChatFieldView()
        refreshPublisher.onNext(())
    }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            if self.chattingsCount > 0 {
                self.chattingView.scrollToRow(at: IndexPath(item: self.chattingsCount - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
            }
        }
    
    private func addViews() {
        sendStack.addArrangedSubview([chatTextField, sendButton])
        view.addSubview([chattingView, sendStack])
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        chattingView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeArea)
        }
        
        sendStack.snp.makeConstraints { make in
            make.top.equalTo(chattingView.snp.bottom).offset(10)
            make.leading.equalTo(safeArea).offset(20)
            make.trailing.equalTo(safeArea).offset(-20)
            make.height.equalTo(40)
        }
        
        sendButton.snp.makeConstraints { make in
            make.width.equalTo(50)
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
            guard let roomid = room.id else {return}
            roomId = roomid
            viewModel.roomId = roomid
            opponentId = room.opponentId
    }
    
    private func configViewController() {
        view.configBackgroundColor()
        view.tappedDismissKeyboard()
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
                    
                    self.viewModel.updateChattingData(chattingData: chatting)
                    
                    chatTextField.text = ""
                    refreshPublisher.onNext(())
                    
                    if self.chattingsCount > 0 {
                        let lastindexPath = IndexPath(row: chattingsCount - 1, section: 0)
                        chattingView.scrollToRow(at: lastindexPath, at: UITableView.ScrollPosition.bottom, animated: true)
                    }
                    
                    DispatchQueue.global().async {
                        self.viewModel.updateRoomData(chattingData: chatting)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        refreshPublisher.onNext(())
    }
    
    @objc func refreshTable(refresh: UIRefreshControl) {
        isRefresh = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            refreshPublisher.onNext(())
            refresh.endRefreshing()
            isRefresh = false
            if self.chattingsCount > 0 {
                let lastindexPath = IndexPath(row: chattingsCount - 1, section: 0)
                chattingView.scrollToRow(at: lastindexPath, at: UITableView.ScrollPosition.bottom, animated: true)
            }
        }
    }
}
// MARK: - TableView
extension ChattingDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chattingsCount = viewModel.chattingArray.count
        print(chattingsCount)
        return chattingsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let item = viewModel.chattingArray[safe: indexPath.row] else { return UITableViewCell() }
        print(item)
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
        return UITableView.automaticDimension
    }
}
// MARK: - Bind
extension ChattingDetailViewController {
    private func bind() {
        let sendInput = ChattingViewModel.Input(listLoad: loadDataPublsher, refresh: refreshPublisher)
        let sendOutput = viewModel.transform(input: sendInput)
        
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
// MARK: - 페이징처리
extension ChattingDetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
           let offsetY = scrollView.contentOffset.y
           let contentHeight = scrollView.contentSize.height
           let height = scrollView.frame.height
           
           if offsetY > (contentHeight - height) {
               if viewModel.isPaging == false {
                   beginPaging()
               }
           }
       }
       
       func beginPaging() {
           viewModel.isPaging = true
           
           chattingView.tableFooterView = footerView
           
           DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
               self.chattingView.tableFooterView = nil
               self.refreshPublisher.onNext(())
               if self.chattingsCount > 0 {
                   self.chattingView.scrollToRow(at: IndexPath(item: self.chattingsCount - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
               }
           }
       }
}
