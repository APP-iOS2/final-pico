//
//  ChatDetailViewController.swift
//  Pico
//
//  Created by 양성혜 on 2023/12/16.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

protocol ChatDetailDelegate: AnyObject {
    func tappedImageView(user: User)
}

final class ChatDetailViewController: UIViewController {
    private let chatDetailTableView = UITableView()
    
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
        textField.autocorrectionType = .default
        textField.spellCheckingType = .default
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
    
    private let viewModel = ChatDetailViewModel()
    private let disposeBag = DisposeBag()
    private let refreshControl = UIRefreshControl()
    private let refreshPublisher = PublishSubject<Void>()
    private let loadDataPublsher = PublishSubject<Void>()
    private let checkReceiveEmptyPublisher = PublishSubject<Void>()
    private var isRefresh = false
    
    private var roomId: String
    private var opponentId: String
    private var opponentName: String = ""
    private var opponentImageURLString: String = ""
    
    private var bottomConstraint = NSLayoutConstraint()
    
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
        reloadTableView()
    }
    
    private func addViews() {
        sendStack.addArrangedSubview([chatTextField, sendButton])
        view.addSubview([chatDetailTableView, sendStack])
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        chatDetailTableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeArea)
        }
        
        sendStack.snp.makeConstraints { make in
            make.top.equalTo(chatDetailTableView.snp.bottom)
            make.leading.equalTo(safeArea).offset(15)
            make.trailing.equalTo(safeArea).offset(-15)
            make.height.equalTo(40)
        }
        
        sendButton.snp.makeConstraints { make in
            make.width.equalTo(30)
        }
        
        bottomConstraint = sendStack.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -5)
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
                    
                    guard let userImageURLString = userData.imageURLs[safe: 0] else { break }
                    opponentImageURLString = userImageURLString
                }
            case .failure(let err):
                print(err)
            }
        }
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
        chatDetailTableView.register(cell: ChatReceiveListTableViewCell.self)
        chatDetailTableView.register(cell: ChatSendListTableViewCell.self)
        chatDetailTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        chatDetailTableView.separatorStyle = .none
        chatDetailTableView.keyboardDismissMode = .onDrag
        chatDetailTableView.dataSource = self
        chatDetailTableView.delegate = self
        
        if #available(iOS 15.0, *) {
            chatDetailTableView.tableHeaderView = UIView()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedChatTableView))
        chatDetailTableView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func tappedChatTableView() {
        chatTextField.resignFirstResponder()
    }
    
    private func configRefresh() {
        refreshControl.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        refreshControl.tintColor = .picoBlue
        chatDetailTableView.refreshControl = refreshControl
    }
    
    private func configSendButton() {
        sendButton.rx.tap
            .bind { [weak self] _ in
                guard let self else { return }
                tappedSendButton()
            }
            .disposed(by: disposeBag)
    }
    
    private func tappedSendButton() {
        sendButton.tappedAnimation()
        if let text = chatTextField.text {
            guard !text.isEmpty else { return }
            
            let chatInfo = ChatDetail.ChatInfo(sendUserId: UserDefaultsManager.shared.getUserData().userId, message: text, sendedDate: Date().timeIntervalSince1970, isReading: false)
            
            viewModel.updateChat(roomId: roomId, receiveUserId: opponentId, chatInfo: chatInfo)
            chatTextField.text = ""
        }
    }
    
    @objc func refreshTable(refresh: UIRefreshControl) {
        isRefresh = true
        refreshPublisher.onNext(())
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            refresh.endRefreshing()
            self.isRefresh = false
            self.reloadTableView()
        }
    }
    
    deinit {
      NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
      NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
// MARK: - TableView
extension ChatDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.chatInfoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = viewModel.chatInfoArray[safe: indexPath.row] else { return UITableViewCell() }
        
        switch item.sendUserId {
        case UserDefaultsManager.shared.getUserData().userId:
            let sendCell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: ChatSendListTableViewCell.self)
            sendCell.config(chatInfo: item)
            sendCell.selectionStyle = .none
            sendCell.backgroundColor = .clear
            return sendCell
            
        default:
            let receiveCell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: ChatReceiveListTableViewCell.self)
            receiveCell.config(chatInfo: item, opponentName: opponentName, opponentImageURLString: opponentImageURLString)
            receiveCell.chatDetailDelegate = self
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
extension ChatDetailViewController {
    private func bind() {
        let input = ChatDetailViewModel.Input(
            listLoad: loadDataPublsher
        )
        let output = viewModel.transform(input: input)
        
        output.reloadChatDetailTableView
            .withUnretained(self)
            .subscribe { viewController, _ in
                viewController.reloadTableView()
            }
            .disposed(by: disposeBag)
    }
    
    private func reloadTableView() {
        chatDetailTableView.reloadData()
        chatDetailTableView.scrollToRow(at: IndexPath(row: viewModel.chatInfoArray.count - 1, section: 0), at: .top, animated: false)
    }
}

extension ChatDetailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tappedSendButton()
        return true
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let window = windowScene?.windows.first
            
            UIView.animate(withDuration: 0.5) {
                self.bottomConstraint.constant = -(keyboardHeight - (window?.safeAreaInsets.bottom ?? 0)) - 5
                self.view.layoutIfNeeded()
            }
        }
        
        UIView.animate(withDuration: 0.5) {} completion: { _ in
            if !self.viewModel.chatInfoArray.isEmpty {
                let lastindexPath = IndexPath(row: self.viewModel.chatInfoArray.count - 1, section: 0)
                self.chatDetailTableView.scrollToRow(at: lastindexPath, at: .top, animated: true)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        self.bottomConstraint.constant = -5
        view.addConstraint(self.bottomConstraint)
        self.view.layoutIfNeeded()
    }
}

extension ChatDetailViewController: ChatDetailDelegate {
    func tappedImageView(user: User) {
        self.navigationController?.popViewController(animated: true)
        
        let viewController = UserDetailViewController()
        viewController.viewModel = UserDetailViewModel(user: user, isHome: false)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
