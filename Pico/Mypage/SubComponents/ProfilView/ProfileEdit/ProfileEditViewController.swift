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
        view.register(ProfileEditImageTableCell.self, forCellReuseIdentifier: Identifier.TableCell.profileEditImageTableCell)
        view.register(ProfileEditNicknameTabelCell.self, forCellReuseIdentifier: Identifier.TableCell.profileEditNicknameTabelCell)
        view.register(ProfileEditBirthTableCell.self, forCellReuseIdentifier: Identifier.TableCell.profileEditBirthTableCell)
        view.register(ProfileEditLoactionTabelCell.self, forCellReuseIdentifier: Identifier.TableCell.profileEditLoactionTabelCell)
        view.register(ProfileEditIntroTabelCell.self, forCellReuseIdentifier: Identifier.TableCell.profileEditIntroTabelCell)
        view.register(ProfileEditTextTabelCell.self, forCellReuseIdentifier: Identifier.TableCell.profileEditTextTabelCell)
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.TableCell.profileEditImageTableCell, for: indexPath) as? ProfileEditImageTableCell else { return UITableViewCell() }
            return cell
        case 1:
            switch indexPath.row {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.TableCell.profileEditBirthTableCell, for: indexPath) as? ProfileEditBirthTableCell else { return UITableViewCell() }
                cell.selectionStyle = .none
                return cell
            case 1:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.TableCell.profileEditNicknameTabelCell, for: indexPath) as? ProfileEditNicknameTabelCell else { return UITableViewCell() }
                cell.selectionStyle = .none
                return cell
            case 2:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.TableCell.profileEditLoactionTabelCell, for: indexPath) as? ProfileEditLoactionTabelCell else { return UITableViewCell() }
                cell.selectionStyle = .none
                return cell
            default:
                return UITableViewCell()
                
            }
        case 2:
            switch indexPath.row {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.TableCell.profileEditIntroTabelCell, for: indexPath) as? ProfileEditIntroTabelCell else { return UITableViewCell() }
                cell.selectionStyle = .none
                return cell
            case 1...4:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.TableCell.profileEditTextTabelCell, for: indexPath) as? ProfileEditTextTabelCell else { return UITableViewCell() }
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
