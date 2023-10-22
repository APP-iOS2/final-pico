//
//  MailReceiveTableListController.swift
//  Pico
//
//  Created by 양성혜 on 2023/10/05.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

protocol MailReceiveDelegate: AnyObject {
    func pushUserDetailViewController(user: User)
}

final class MailReceiveTableListController: BaseViewController {
    
    private let viewModel = MailReceiveModel()
    private let disposeBag = DisposeBag()
    
    private let emptyView: EmptyViewController = EmptyViewController(type: .message)
    
    private let refreshControl = UIRefreshControl()
    private let refreshPublisher = PublishSubject<Void>()
    private let loadDataPublsher = PublishSubject<Void>()
    private let checkReceiveEmptyPublisher = PublishSubject<Void>()
    private let deleteReceivePublisher = PublishSubject<String>()
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDataPublsher.onNext(())
        refreshPublisher.onNext(())
        checkReceiveEmptyPublisher.onNext(())
        mailListTableView.reloadData()
    }
    // MARK: - config
    private func configTableView() {
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            refreshPublisher.onNext(())
            refresh.endRefreshing()
        }
    }
}
// MARK: - UIMailTableView
extension MailReceiveTableListController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.receiveList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: MailListTableViewCell.self)
        guard let item = viewModel.receiveList[safe: indexPath.row] else { return UITableViewCell() }
        cell.config(senderUser: item, type: .receive)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.receiveList[indexPath.row]
        viewModel.updateNewData(data: item)
        let mailReceiveView = MailReceiveViewController()
        mailReceiveView.modalPresentationStyle = .formSheet
        mailReceiveView.mailReceiveDelegate = self
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
        guard let item = viewModel.receiveList[safe: indexPath.row] else { return }
        self.deleteReceivePublisher.onNext(item.id)
    }
}
// MARK: - bind
extension MailReceiveTableListController {
    private func bind() {
        let input = MailReceiveModel.Input(listLoad: loadDataPublsher,
                                           deleteUser: deleteReceivePublisher,
                                           refresh: refreshPublisher,
                                           isReceiveEmptyChecked: checkReceiveEmptyPublisher)
        let output = viewModel.transform(input: input)
        
        output.receiveIsEmpty
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
                viewController.checkReceiveEmptyPublisher.onNext(())
            }
            .disposed(by: disposeBag)
    }
}
// MARK: - Paging
extension MailReceiveTableListController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let contentOffsetY = scrollView.contentOffset.y
        let tableViewContentSizeY = mailListTableView.contentSize.height
        
        if contentOffsetY > tableViewContentSizeY - scrollView.frame.size.height {
            mailListTableView.reloadData()
            loadDataPublsher.onNext(())
        }
    }
}
// MARK: - GoDetailView
extension MailReceiveTableListController: MailReceiveDelegate {
    func pushUserDetailViewController(user: User) {
        let viewController = UserDetailViewController()
        viewController.viewModel = UserDetailViewModel(user: user)
        self.mailViewController.navigationController?.pushViewController(viewController, animated: true)
    }
}
