//
//  MailSendTableListController.swift
//  Pico
//
//  Created by 양성혜 on 2023/10/05.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

protocol MailSendDelegate: AnyObject {
    func pushUserDetailViewController(user: User)
}

final class MailSendTableListController: BaseViewController {
    
    private let viewModel = MailSendViewModel()
    private let disposeBag = DisposeBag()
    private let emptyView: EmptyViewController = EmptyViewController(type: .message)
    private let refreshControl = UIRefreshControl()
    private let refreshPublisher = PublishSubject<Void>()
    private let loadDataPublsher = PublishSubject<Void>()
    private let checkSendEmptyPublisher = PublishSubject<Void>()
    private let deleteSendPublisher = PublishSubject<String>()
    private let footerView = FooterView()
    private var isRefresh = false
    
    private let mailListTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(cell: MailListTableViewCell.self)
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        return tableView
    }()
    
    var mailViewController: MailViewController
    
    init(viewController: MailViewController) {
        self.mailViewController = viewController
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - MailView +LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configRefresh()
        configTableView()
        loadDataPublsher.onNext(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.startIndex = 0
        loadDataPublsher.onNext(())
        refreshPublisher.onNext(())
        checkSendEmptyPublisher.onNext(())
        mailListTableView.reloadData()
    }
    // MARK: - config
    private func configTableView() {
        
        footerView.frame = CGRect(x: 0, y: 0, width: mailListTableView.bounds.size.width, height: 80)
        mailListTableView.dataSource = self
        mailListTableView.delegate = self
    }
    
    private func configRefresh() {
        refreshControl.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        refreshControl.tintColor = .picoBlue
        mailListTableView.refreshControl = refreshControl
    }
    
    // MARK: - objc
    @objc private func refreshTable(refresh: UIRefreshControl) {
        isRefresh = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            viewModel.startIndex = 0
            refreshPublisher.onNext(())
            refresh.endRefreshing()
            isRefresh = false
        }
    }
}
// MARK: - UIMailTableView
extension MailSendTableListController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: MailListTableViewCell.self)
        guard let item = viewModel.sendList[safe: indexPath.row] else { return UITableViewCell() }
        cell.config(senderUser: item, type: .send)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.sendList[indexPath.row]
        let mailReceiveView = MailReceiveViewController()
        mailReceiveView.modalPresentationStyle = .formSheet
        mailReceiveView.mailSendDelegate = self
        mailReceiveView.configData(mailSender: item)
        self.present(mailReceiveView, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let item = viewModel.sendList[safe: indexPath.row] else { return }
        self.deleteSendPublisher.onNext(item.id)
    }
}
// MARK: - bind
extension MailSendTableListController {
    private func bind() {
        let input = MailSendViewModel.Input(listLoad: loadDataPublsher,
                                        deleteUser: deleteSendPublisher,
                                        refresh: refreshPublisher,
                                        isSendEmptyChecked: checkSendEmptyPublisher)
        let output = viewModel.transform(input: input)
        
        output.sendIsEmpty
            .withUnretained(self)
            .subscribe(onNext: { viewController, isEmpty in
                if isEmpty {
                    viewController.addChild(viewController.emptyView)
                    viewController.view.addSubview(viewController.emptyView.view ?? UIView())
                    viewController.emptyView.didMove(toParent: self)
                    viewController.emptyView.view.snp.makeConstraints { make in
                        make.edges.equalToSuperview()
                    }
                } else {
                    viewController.view.addSubview(viewController.mailListTableView)
                    viewController.mailListTableView.snp.makeConstraints { make in
                        make.edges.equalToSuperview()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        output.reloadMailTableView
            .withUnretained(self)
            .subscribe { viewController, _ in
                viewController.mailListTableView.reloadData()
                viewController.checkSendEmptyPublisher.onNext(())
            }
            .disposed(by: disposeBag)
    }
}
// MARK: - Paging
extension MailSendTableListController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let contentOffsetY = scrollView.contentOffset.y
        let tableViewContentSizeY = mailListTableView.contentSize.height
        
        if contentOffsetY > tableViewContentSizeY - scrollView.frame.size.height && !isRefresh {
            mailListTableView.tableFooterView = footerView
            loadDataPublsher.onNext(())
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self else { return }
                
                mailListTableView.reloadData()
                mailListTableView.tableFooterView = nil
            }
        }
    }
}
// MARK: - GoDetailView
extension MailSendTableListController: MailSendDelegate {
    func pushUserDetailViewController(user: User) {
        let viewController = UserDetailViewController()
        viewController.viewModel = UserDetailViewModel(user: user, isHome: false)
        self.mailViewController.navigationController?.pushViewController(viewController, animated: true)
    }
}
