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
    
    private let likeButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.setImage(UIImage(systemName: "hand.thumbsup.circle.fill"), for: .normal)
        return button
    }()
    
    private let disLikeButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.setImage(UIImage(systemName: "hand.thumbsdown.circle.fill"), for: .normal)
        return button
    }()
    
    private let actionSheetController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addViews()
        makeConstraints()
        configTableView()
        configureNavigationBar()
        configActionSheet()
    }
    
    func configActionSheet() {
        let actionReport = UIAlertAction(title: "신고", style: .default, handler: nil)
        let actionBlock = UIAlertAction(title: "차단", style: .default, handler: nil)
        let actionDrink = UIAlertAction(title: "취한거같아요", style: .destructive, handler: nil)
        let actionCancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        actionSheetController.addAction(actionReport)
        actionSheetController.addAction(actionBlock)
        actionSheetController.addAction(actionDrink)
        actionSheetController.addAction(actionCancel)
    }
    
    @objc func tappedNavigationButton() {
        self.present(actionSheetController, animated: true)
    }
    
    private func configureNavigationBar() {
        self.navigationItem.title = "윈터, 24"
        let rightBarButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(tappedNavigationButton))
        self.navigationItem.rightBarButtonItem = rightBarButton
        self.navigationController?.navigationBar.tintColor = .black
    }
    
    final private func configTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserImageTableViewCell.self, forCellReuseIdentifier: Identifier.TableCell.userImageTableCell)
        tableView.register(TopUserTableViewCell.self, forCellReuseIdentifier: Identifier.TableCell.topUserTableCell)
        tableView.register(MiddleUserTableViewCell.self, forCellReuseIdentifier: Identifier.TableCell.middleUserTableCell)
        tableView.register(BottomUserTableViewCell.self, forCellReuseIdentifier: Identifier.TableCell.bottomUserTableCell)
    }
    
    final private func addViews() {
        [tableView, likeButton, disLikeButton].forEach {
            view.addSubview($0)
        }
    }
    
    final private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        tableView.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalTo(safeArea)
        }
    }
}

extension UserDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    final func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.userData.subInfo != nil {
            return 4
        } else {
            return 2
        }
    }
    
    final func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
            
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.TableCell.userImageTableCell, for: indexPath) as? UserImageTableViewCell else { return UITableViewCell() }
            cell.config(images: viewModel.userData.imageURLs)
            cell.selectionStyle = .none
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.TableCell.topUserTableCell, for: indexPath) as? TopUserTableViewCell else { return UITableViewCell() }
            cell.config(mbti: .infp, nameAgeText: viewModel.userData.nickName, locationText: viewModel.userData.location.address, heightText: "112")
            cell.selectionStyle = .none
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.TableCell.middleUserTableCell, for: indexPath) as? MiddleUserTableViewCell ?? UITableViewCell()
            cell.selectionStyle = .none
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.TableCell.bottomUserTableCell, for: indexPath) as? BottomUserTableViewCell ?? UITableViewCell()
            cell.selectionStyle = .none
            return cell
        default:
            let cell = UITableViewCell()
            return cell
        }
    }
    
    final func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return CGFloat(Screen.height * 0.4)
        case 1:
            return CGFloat(Screen.height * 0.2)
        case 2:
            return CGFloat(Screen.height * 0.3)
        case 3:
            return CGFloat(Screen.height * 0.6)
        default:
            return CGFloat(200)
        }
    }
}
