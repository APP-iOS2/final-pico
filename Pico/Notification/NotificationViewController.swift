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
    private let emptyView: EmptyViewController = EmptyViewController(type: .notification)
    private let tableView = UITableView()
    private let viewModel = NotificationViewModel()
    private var disposeBag = DisposeBag()
    private let refreshControl = UIRefreshControl()
    private let refreshPublisher = PublishSubject<Void>()
    private let loadDataPublsher = PublishSubject<Void>()
    private let checkEmptyPublisher = PublishSubject<Void>()
    private let footerView = FooterView()
    private var isRefresh = false
    private var cellTapped: Bool = false
    private var detailUser: User?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cellTapped = false
        tableView.reloadData()
        checkEmptyPublisher.onNext(())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let user = detailUser {
            let viewController = UserDetailViewController()
            viewController.viewModel = UserDetailViewModel(user: user, isHome: false)
            self.navigationController?.pushViewController(viewController, animated: true)
        } else {
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        configViewController()
        configTableView()
        configRefresh()
        bind()
        loadDataPublsher.onNext(())
    }
    
    private func configViewController() {
        view.configBackgroundColor()
        configNavigationBackButton()
        navigationItem.title = "알림"
        tabBarController?.tabBar.isHidden = true
    }
    
    private func configTableView() {
        tableView.register(cell: NotificationTableViewCell.self)
        footerView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 80)
        if #available(iOS 15.0, *) {
            tableView.tableHeaderView = UIView()
        }
        tableView.rowHeight = 90
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func configRefresh() {
        refreshControl.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        refreshControl.tintColor = .picoBlue
        tableView.refreshControl = refreshControl
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
extension NotificationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: NotificationTableViewCell.self)
        guard let item = viewModel.notifications[safe: indexPath.row] else { return UITableViewCell() }
        cell.configData(notitype: item.notiType, imageUrl: item.imageUrl, nickName: item.name, age: item.age, mbti: item.mbti, date: item.createDate)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = viewModel.notifications[safe: indexPath.row] else { return }
        FirestoreService.shared.loadDocument(collectionId: .users, documentId: item.sendId, dataType: User.self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                guard data != nil else {
                    showCustomAlert(alertType: .onlyConfirm, titleText: "탈퇴 회원", messageText: "탈퇴된 회원입니다.", confirmButtonText: "확인")
                    return
                }
                if cellTapped { return }
                cellTapped = true
                if item.notiType == .like {
                    FirestoreService.shared.loadDocument(collectionId: .users, documentId: item.sendId, dataType: User.self) { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case .success(let data):
                            guard let data = data else { return }
                            detailUser = data
                            navigationController?.popViewController(animated: false)
                        case .failure(let error):
                            print(error)
                            return
                        }
                    }
                } else {
                    if let tabBarController = self.tabBarController as? TabBarController {
                        if tabBarController.selectedIndex == 1 {
                            self.navigationController?.popViewController(animated: true)
                            return
                        }
                        tabBarController.selectedIndex = 1
                        let viewControllers = self.navigationController?.viewControllers
                        self.navigationController?.setViewControllers(viewControllers ?? [], animated: false)
                    }
                }
            case .failure(let error):
                print(error)
                showCustomAlert(alertType: .onlyConfirm, titleText: "탈퇴 회원", messageText: "탈퇴된 회원입니다.", confirmButtonText: "확인")
                return
            }
        }
    }
}

// MARK: - Bind
extension NotificationViewController {
    private func bind() {
        let input = NotificationViewModel.Input(listLoad: loadDataPublsher, refresh: refreshPublisher, checkEmpty: checkEmptyPublisher)
        let output = viewModel.transform(input: input)
        
        output.notificationIsEmpty
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
                    viewController.view.addSubview(viewController.tableView)
                    viewController.tableView.snp.makeConstraints { make in
                        make.edges.equalToSuperview()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        output.reloadTableView
            .withUnretained(self)
            .subscribe { viewController, _ in
                viewController.tableView.reloadData()
                viewController.checkEmptyPublisher.onNext(())
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - 페이징처리
extension NotificationViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let contentOffsetY = scrollView.contentOffset.y
        let tableViewContentSizeY = tableView.contentSize.height
        
        if contentOffsetY > tableViewContentSizeY - scrollView.frame.size.height && !isRefresh {
            
            tableView.tableFooterView = footerView
            
            loadDataPublsher.onNext(())
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.tableView.tableFooterView = nil
            }
        }
    }
}
