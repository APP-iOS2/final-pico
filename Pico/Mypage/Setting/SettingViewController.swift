//
//  SettingViewController.swift
//  Pico
//
//  Created by 김민기 on 2023/09/26.
//

import UIKit
import SnapKit

final class SettingViewController: UIViewController {
   
    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.register(cell: SettingPrivateTableCell.self)
        view.register(cell: SettingNotiTableCell.self)
        view.register(cell: SettingTableCell.self)
        view.configBackgroundColor()
        view.separatorStyle = .none
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavigation()
        configTableView()
        addViews()
        makeConstraints()
    }
    
    private func configNavigation() {
        title = "설정"
    }
    
    private func configTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func addViews() {
        [tableView].forEach {
            view.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func logout() {
        /*
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
         */
        let signViewController = UINavigationController(rootViewController: SignViewController())
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootView(signViewController, animated: true)
    }
}

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: 
            return 1
        case 1: 
            return 2
        case 2:
            return 7
        case 3: 
            return 2
        default: 
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: SettingPrivateTableCell.self)
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: SettingNotiTableCell.self)

            return cell
        case 2...3:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: SettingTableCell.self)
            
            if indexPath.section == 3 {
                cell.configure(contentLabel: "로그아웃")
            }
            return cell

        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 55
        case 1:
            return 65
        case 2...3:
            return 40
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SettingTableHeaderView()
        switch section {
        case 0:
            let view = UIView()
            return view
        case 1:
            view.configure(headerLabel: "알림")
        case 2:
            view.configure(headerLabel: "약관")
        case 3:
            view.configure(headerLabel: "계정")
        default: 
            return nil
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        default:
            return 20.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 3:
            UserDefaultsManager.shared.removeAll()
            logout()
        default:
            break
        }
    }
}
