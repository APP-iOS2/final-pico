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
    
    private let chattingView: UITableView = {
        let uiTableView = UITableView()
        uiTableView.backgroundColor = .picoGray
        return uiTableView
    }()
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
        button.backgroundColor = .white
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
        loadDataPublsher.onNext(())
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
            make.leading.equalTo(safeArea).offset(10)
            make.trailing.bottom.equalTo(safeArea).offset(-10)
            make.height.equalTo(40)
        }
        
        chattingView.snp.makeConstraints { make in
            make.top.trailing.leading.equalTo(safeArea)
            make.bottom.equalTo(sendStack.snp.top).offset(-10)
        }
    }
    
    private func configViewController() {
        view.configBackgroundColor()
        navigationItem.title = opponentName
        navigationItem.titleView?.tintColor = .picoAlphaBlue
        tabBarController?.tabBar.isHidden = true
    }
    
    private func configSendButton() {
        sendButton.rx.tap
            .bind { [weak self] _ in
                guard let self = self  else { return }
                self.sendButton.tappedAnimation()
                if let text = self.chatTextField.text {
                    // sender: 로그인한 사람, recevie 받는 사람
                    
                    self.viewModel.updateRoomData(chattingData: Chatting.ChattingInfo(roomId: roomId, sendUserId: UserDefaultsManager.shared.getUserData().userId, receiveUserId: opponentId, message: text, sendedDate: Date().timeIntervalSince1970, isReading: true, messageType: .send))
                    
                    chatTextField.text = ""
                }
            }
            .disposed(by: disposeBag)
        chattingView.reloadData()
    }
    
    private func configTableView() {
        chattingView.register(cell: ChattingReceiveListTableViewCell.self)
        chattingView.register(cell: ChattingSendListTableViewCell.self)
        footerView.frame = CGRect(x: 0, y: 0, width: chattingView.bounds.size.width, height: 80)
        if #available(iOS 15.0, *) {
            chattingView.tableHeaderView = UIView()
        }
        chattingView.rowHeight = 40
        chattingView.dataSource = self
        chattingView.delegate = self
    }
    
    private func configRefresh() {
        refreshControl.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        refreshControl.tintColor = .picoBlue
        chattingView.refreshControl = refreshControl
    }
    
    @objc func refreshTable(refresh: UIRefreshControl) {
        isRefresh = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            refreshPublisher.onNext(())
            refresh.endRefreshing()
            isRefresh = false
        }
    }
}
// MARK: - TableView
extension ChattingDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sender = viewModel.sendChattingList.count
        let receive = viewModel.receiveChattingList.count
        print(sender + receive)
        return sender + receive
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var chattingArray = viewModel.sendChattingList + viewModel.receiveChattingList
        chattingArray.sort(by: {$0.sendedDate < $1.sendedDate})
        
        guard let item = chattingArray[safe: indexPath.row] else { return UITableViewCell() }
        print(item)
        switch item.messageType {
        case .receive:
            let receiveCell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: ChattingReceiveListTableViewCell.self)
            receiveCell.config(chatting: item)
            return receiveCell
        case .send:
            let sendCell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: ChattingSendListTableViewCell.self)
            sendCell.config(chatting: item)
            return sendCell
        }
    }
}
// MARK: - Bind
extension ChattingDetailViewController {
    private func bind() {
        let input = ChattingViewModel.Input(listLoad: loadDataPublsher, refresh: refreshPublisher)
        let output = viewModel.transform(input: input)
        
        output.reloadChattingTableView
            .withUnretained(self)
            .subscribe { viewController, _ in
                viewController.chattingView.reloadData()
            }
            .disposed(by: disposeBag)
    }
}
