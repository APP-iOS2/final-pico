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
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configViewController()
        addViews()
        makeConstraints()
        configTableView()
        configTableviewDelegate()
        configTableviewDatasource()
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
    }
    
    private func addViews() {
        view.addSubview(tableView)
    }
    
    private func makeConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - UITableView+Rx
extension NotificationViewController {
    private func configTableviewDatasource() {
        viewModel.notificationsRx
            .bind(to: tableView.rx.items(cellIdentifier: NotificationTableViewCell.reuseIdentifier, cellType: NotificationTableViewCell.self)) { _, item, cell in
                cell.configData(notitype: item.notiType, imageUrl: item.imageUrl, nickName: item.name, age: item.age, mbti: item.mbti, date: item.createDate)
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
            viewModel.loadNextPage()
        }
    }
}
