//
//  NotificationViewController.swift
//  Pico
//
//  Created by 방유빈 on 2023/09/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class NotificationViewController: UIViewController {
    private let tableView = UITableView()
    private let viewModel = NotificationViewModel()
    private var disposeBag = DisposeBag()
    private let refreshControl = UIRefreshControl()
    private let refreshPublisher = PublishSubject<Void>()
    private let loadDataPublsher = PublishSubject<Void>()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configViewController()
        addViews()
        makeConstraints()
        configTableView()
        configTableviewDelegate()
        configRefresh()
        bind()
        loadDataPublsher.onNext(())
    }
    
    private func configViewController() {
        view.configBackgroundColor()
        configNavigationBackButton()
        navigationItem.title = "알림"
    }
    
    private func configTableView() {
        tableView.register(cell: NotificationTableViewCell.self)
        if #available(iOS 15.0, *) {
            tableView.tableHeaderView = UIView()
        }
        tableView.rowHeight = 90
        tableView.dataSource = self
    }
    
    private func configRefresh() {
        refreshControl.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        refreshControl.tintColor = .picoBlue
        tableView.refreshControl = refreshControl
    }
    
    private func addViews() {
        view.addSubview(tableView)
    }
    
    private func makeConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    @objc func refreshTable(refresh: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            refreshPublisher.onNext(())
            refresh.endRefreshing()
        }
    }
}

// MARK: - DataSource
extension NotificationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: NotificationTableViewCell.self)
        let item = viewModel.notifications[indexPath.row]
        cell.configData(notitype: item.notiType, imageUrl: item.imageUrl, nickName: item.name, age: item.age, mbti: item.mbti, date: item.createDate)
        return cell
    }
}

// MARK: - Bind
extension NotificationViewController {
    private func bind() {
        let input = NotificationViewModel.Input(listLoad: loadDataPublsher, refresh: refreshPublisher)
        let output = viewModel.transform(input: input)
        
        output.reloadTableView
            .withUnretained(self)
            .subscribe { viewController, _ in
                viewController.tableView.reloadData()
            }
            .disposed(by: disposeBag)
    }
    private func configTableviewDelegate() {
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        tableView.rx.modelSelected(Noti.self)
            .subscribe(onNext: { item in
                if item.notiType == .like {
                    let viewController = UserDetailViewController()
                    self.navigationController?.pushViewController(viewController, animated: true)
                } else {
                    if let tabBarController = self.tabBarController as? TabBarController {
                        tabBarController.selectedIndex = 1
                        let viewControllers = self.navigationController?.viewControllers
                        self.navigationController?.setViewControllers(viewControllers ?? [], animated: false)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - 페이징처리
extension NotificationViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let contentOffsetY = scrollView.contentOffset.y
        let tableViewContentSizeY = tableView.contentSize.height
        
        if contentOffsetY > tableViewContentSizeY - scrollView.frame.size.height {
            loadDataPublsher.onNext(())
        }
    }
}
