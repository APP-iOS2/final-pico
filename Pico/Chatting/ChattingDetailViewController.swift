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
    private let chattingTableView = UITableView()
    
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
    
    private let viewModel = ChattingDetailViewModel()
    private let disposeBag = DisposeBag()
    private let refreshControl = UIRefreshControl()
    private let refreshPublisher = PublishSubject<Void>()
    private let loadDataPublsher = PublishSubject<Void>()
    private let checkReceiveEmptyPublisher = PublishSubject<Void>()
    private var isRefresh = false
    
    private var roomId: String
    private var opponentId: String
    private var opponentName: String = ""
    
    var chattingsCount: Int = 0
    var bottomConstraint = NSLayoutConstraint()
    
    init(roomId: String, opponentId: String) {
        self.roomId = roomId
        self.opponentId = opponentId
        super.init(nibName: nil, bundle: nil)
        viewModel.roomId = roomId
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        addViews()
        makeConstraints()
        configViewController()
        configTableView()
        configRefresh()
        configSendButton()
        loadDataPublsher.onNext(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configChatFieldView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        chattingTableView.reloadData()
    }
    
    private func addViews() {
        sendStack.addArrangedSubview([chatTextField, sendButton])
        view.addSubview([chattingTableView, sendStack])
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        chattingTableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeArea)
        }
        
        sendStack.snp.makeConstraints { make in
            make.top.equalTo(chattingTableView.snp.bottom).offset(10)
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
    
    func configData(roomInfo: ChatRoom.RoomInfo) {
        FirestoreService.shared.searchDocumentWithEqualField(collectionId: .users, field: "id", compareWith: roomInfo.opponentId, dataType: User.self) { [weak self] result in
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
        chattingTableView.register(cell: ChattingReceiveListTableViewCell.self)
        chattingTableView.register(cell: ChattingSendListTableViewCell.self)
        if #available(iOS 15.0, *) {
            chattingTableView.tableHeaderView = UIView()
        }
        chattingTableView.separatorStyle = .none
        chattingTableView.keyboardDismissMode = .onDrag
        chattingTableView.dataSource = self
        chattingTableView.delegate = self
    }
    
    private func configRefresh() {
        refreshControl.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        refreshControl.tintColor = .picoBlue
        chattingTableView.refreshControl = refreshControl
    }
    
    private func configSendButton() {
        sendButton.rx.tap
            .bind { [weak self] _ in
                guard let self = self  else { return }
                self.sendButton.tappedAnimation()
                if let text = self.chatTextField.text {
                    let chatInfo = ChatDetail.ChatInfo(sendUserId: UserDefaultsManager.shared.getUserData().userId, message: text, sendedDate: Date().timeIntervalSince1970, isReading: false)
                    
                    self.viewModel.updateChattingData(roomId: roomId, receiveUserId: opponentId, chatInfo: chatInfo)
                    self.viewModel.updateRoomData(roomId: roomId, receiveUserId: opponentId)
                    chatTextField.text = ""
                }
            }
            .disposed(by: disposeBag)
    }
    
    @objc func refreshTable(refresh: UIRefreshControl) {
        isRefresh = true
        refreshPublisher.onNext(())
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            refresh.endRefreshing()
            isRefresh = false
            chattingTableView.reloadData()
        }
    }
}
// MARK: - TableView
extension ChattingDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chattingsCount = viewModel.chattingArray.count
        return chattingsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = viewModel.chattingArray[safe: indexPath.row] else { return UITableViewCell() }
        
        switch item.sendUserId {
        case UserDefaultsManager.shared.getUserData().userId:
            let sendCell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: ChattingSendListTableViewCell.self)
            sendCell.config(chatInfo: item)
            sendCell.selectionStyle = .none
            sendCell.backgroundColor = .clear
            return sendCell
            
        default:
            let receiveCell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: ChattingReceiveListTableViewCell.self)
            receiveCell.config(chatInfo: item)
            receiveCell.selectionStyle = .none
            receiveCell.backgroundColor = .clear
            return receiveCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
// MARK: - Bind
extension ChattingDetailViewController {
    private func bind() {
        let sendInput = ChattingDetailViewModel.Input(
            listLoad: loadDataPublsher
        )
        let sendOutput = viewModel.transform(input: sendInput)
        
        sendOutput.reloadChattingTableView
            .withUnretained(self)
            .subscribe { viewController, _ in
                viewController.chattingTableView.reloadData()
                viewController.chattingTableView.scrollToRow(at: IndexPath(row: viewController.viewModel.chattingArray.count - 1, section: 0), at: .top, animated: false)
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
                let lastindexPath = IndexPath(row: self.chattingsCount - 1, section: 0)
                self.chattingTableView.scrollToRow(at: lastindexPath, at: .top, animated: false)
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
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        let contentOffsetY = scrollView.contentOffset.y
//        let tableViewContentSizeY = chattingTableView.contentSize.height
//        
//        if contentOffsetY > tableViewContentSizeY - scrollView.frame.size.height {
//            
//            chattingTableView.tableFooterView = footerView
//            refreshPublisher.onNext(())
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                self.chattingTableView.tableFooterView = nil
//                self.chattingTableView.reloadData()
//                
//                if self.chattingsCount > 0 {
//                    let lastindexPath = IndexPath(row: self.chattingsCount - 1, section: 0)
//                    self.chattingTableView.scrollToRow(at: lastindexPath, at: .top, animated: false)
//                }
//            }
//        }
//    }
}
