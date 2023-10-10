//
//  ProfileEditViewController.swift
//  Pico
//
//  Created by 김민기 on 2023/09/27.
//

import UIKit

final class ProfileEditViewController: UIViewController {
    
    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.register(cell: ProfileEditImageTableCell.self)
        view.register(cell: ProfileEditNicknameTabelCell.self)
        view.register(cell: ProfileEditBirthTableCell.self)
        view.register(cell: ProfileEditLoactionTabelCell.self)
        view.register(cell: ProfileEditIntroTabelCell.self)
        view.register(cell: ProfileEditTextTabelCell.self)
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
        title = "프로필 수정"
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
}

extension ProfileEditViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        case 2:
            return 7
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
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: ProfileEditImageTableCell.self)
            return cell
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: ProfileEditBirthTableCell.self)
                cell.selectionStyle = .none
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: ProfileEditNicknameTabelCell.self)
                cell.selectionStyle = .none
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: ProfileEditLoactionTabelCell.self)
                cell.selectionStyle = .none
                return cell
            default:
                return UITableViewCell()
                
            }
        case 2:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: ProfileEditIntroTabelCell.self)
                cell.selectionStyle = .none
                return cell
            case 1...4:
                let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: ProfileEditTextTabelCell.self)
                cell.selectionStyle = .none
                return cell
            case 5...6: return UITableViewCell()
            default:
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 155
        case 1:
            return 45
        case 2:
            if indexPath.row != 0 {
                return 45
            } else {
                return 100
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0...1:
            let view = UIView()
            return view
        case 2:
            let view = ProfileEditTableHeaderView()
            return view
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 20.0
        case 1:
            return 25
        case 2:
            return 20
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
