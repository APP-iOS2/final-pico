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
        tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: Identifier.TableCell.notiTableCell)
        if #available(iOS 15.0, *) {
            tableView.tableHeaderView = UIView()
        }
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

extension NotificationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - UITableView+Rx
extension NotificationViewController {
    private func configTableviewDatasource() {
        viewModel.notifications
            .bind(to: tableView.rx.items(cellIdentifier: Identifier.TableCell.notiTableCell, cellType: NotificationTableViewCell.self)) { _, item, cell in
                cell.configData(notitype: item.notiType, imageUrl: item.imageUrl, nickName: item.name, age: item.age, mbti: item.mbti)
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
