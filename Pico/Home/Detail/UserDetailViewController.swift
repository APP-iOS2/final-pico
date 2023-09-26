//
//  DetailViewController.swift
//  Pico
//
//  Created by 신희권 on 2023/09/25.
//

import UIKit
import SnapKit

final class UserDetailViewController: UIViewController {
    private let userInfo = User.userData
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private let navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar()
        navigationBar.barTintColor = .systemBackground
        return navigationBar
    }()
    
    private let navItem: UINavigationItem = {
        let navigationItem = UINavigationItem(title: "카리나, 24")
        return navigationItem
    }()
    
    private let leftBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .plain, target: UserDetailViewController.self, action: #selector(tappedNavigationButton))
        barButtonItem.tintColor = .black
        return barButtonItem
    }()
    
    private let rightBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: UserDetailViewController.self, action: #selector(tappedNavigationButton))
        barButtonItem.tintColor = .black
        return barButtonItem
    }()
    
    private let separatorView: UIView = {
        let uiView = UIView()
        uiView.backgroundColor = .systemGray5
        return uiView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addViews()
        configTableView()
        makeConstraints()
        configureNavigationBar()
    }
    
    @objc func tappedNavigationButton() {
        // Action
    }
    
    private func configureNavigationBar() {
        navItem.leftBarButtonItem = leftBarButton
        navItem.rightBarButtonItem = rightBarButton
        navigationBar.setItems([navItem], animated: true)
    }
    
    final private func configTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TopUserTableViewCell.self, forCellReuseIdentifier: TopUserTableViewCell.id)
        tableView.register(MiddleUserTableViewCell.self, forCellReuseIdentifier: MiddleUserTableViewCell.id)
        tableView.register(BottomUserTableViewCell.self, forCellReuseIdentifier: BottomUserTableViewCell.id)
    }
    
    final private func addViews() {
        [navigationBar, tableView].forEach {
            view.addSubview($0)
        }
    }
    
    final private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        navigationBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeArea)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.leading.trailing.bottom.equalTo(safeArea)
        }
    }
}

extension UserDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    final func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    final func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:

            guard let cell = tableView.dequeueReusableCell(withIdentifier: TopUserTableViewCell.id, for: indexPath) as? TopUserTableViewCell else { return UITableViewCell() }
            cell.heightLabel.text = "\(userInfo.subInfo?.height ?? 0 ) cm"
            cell.nameAgeLabel.text = "\(userInfo.nickName)"
            cell.selectionStyle = .none
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: MiddleUserTableViewCell.id, for: indexPath) as? MiddleUserTableViewCell ?? UITableViewCell()
            cell.selectionStyle = .none
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: BottomUserTableViewCell.id, for: indexPath) as? BottomUserTableViewCell ?? UITableViewCell()
            cell.selectionStyle = .none
            return cell
        default:
            let cell = UITableViewCell()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return CGFloat(400)
    }
}
