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
    private let viewModel = UserDetailViewModel()
    
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
        tableView.register(TopUserTableViewCell.self, forCellReuseIdentifier: Identifier.TableCell.topUserTableCell)
        tableView.register(MiddleUserTableViewCell.self, forCellReuseIdentifier: Identifier.TableCell.middleUserTableCell)
        tableView.register(BottomUserTableViewCell.self, forCellReuseIdentifier:Identifier.TableCell.bottomUserTableCell)
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
        if viewModel.userData.subInfo != nil {
            return 3
        } else {
            return 2
        }
    }
    
    final func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.TableCell.topUserTableCell, for: indexPath) as? TopUserTableViewCell else { return UITableViewCell() }
            cell.config(mbti: .infp, nameAgeText: viewModel.userData.nickName, locationText: viewModel.userData.location.address, heightText: "112")
            cell.selectionStyle = .none
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.TableCell.middleUserTableCell, for: indexPath) as? MiddleUserTableViewCell ?? UITableViewCell()
            cell.selectionStyle = .none
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.TableCell.bottomUserTableCell, for: indexPath) as? BottomUserTableViewCell ?? UITableViewCell()
            cell.selectionStyle = .none
            return cell
        default:
            let cell = UITableViewCell()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return CGFloat(400)
        case 1:
            return CGFloat(250)
        case 2:
            return CGFloat(1000)
            
        default:
            return CGFloat(200)
        }
        
    }
}
