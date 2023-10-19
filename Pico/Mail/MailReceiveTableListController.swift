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

final class MailReceiveTableListController: BaseViewController {
    
    private let viewModel = MailReceiveModel()
    private let disposeBag = DisposeBag()
    
    private let emptyView: EmptyViewController = EmptyViewController(type: .message)
    private let refreshControl = UIRefreshControl()
    private let refreshPublisher = PublishSubject<Void>()
    private let loadDataPublsher = PublishSubject<Void>()
    private let checkReceiveEmptyPublisher = PublishSubject<Void>()
    
    private let mailListTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(cell: MailListTableViewCell.self)
        return tableView
    }()
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
        mailListTableView.reloadData()
        checkReceiveEmptyPublisher.onNext(())
    }
    // MARK: - config
    private func configTableView() {
        mailListTableView.rowHeight = 80
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
        let item = viewModel.receiveList[indexPath.row]
        cell.getData(senderUser: item, type: .receive)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.receiveList[indexPath.row]
        viewModel.updateNewData(data: item)
        configTableviewSelect(item: item)
        
    }
    
    private func configTableviewSelect(item: Mail.MailInfo) {
        let mailReceiveView = MailReceiveViewController()
        mailReceiveView.modalPresentationStyle = .formSheet
        mailReceiveView.configData(mailSender: item)
        self.present(mailReceiveView, animated: true, completion: nil)
    }
}
// MARK: - bind
extension MailReceiveTableListController {
    private func bind() {
        let input = MailReceiveModel.Input(listLoad: loadDataPublsher,
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
                        make.top.leading.equalToSuperview().offset(10)
                        make.trailing.bottom.equalToSuperview().offset(-10)
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
