//
//  SettingSecessionViewController.swift
//  Pico
//
//  Created by 김민기 on 2023/10/19.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SettingSecessionViewController: UIViewController {

    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.register(cell: SettingTableCell.self)
        view.configBackgroundColor()
        view.separatorStyle = .none
        view.rowHeight = 50
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewConfig()
        addSubView()
        makeConstraints()
        configTableView()
    }
    private func configTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
  
    private func viewConfig() {
        title = "회원관리"
        view.backgroundColor = .systemBackground
    }
    
    private func addSubView() {
        view.addSubview([tableView])
    }
    
    private func makeConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func withdrawUser() {

        NotificationService.shared.fcmTokenDelete()
        UserDefaultsManager.shared.removeAll()
        let signViewController = UINavigationController(rootViewController: SignViewController())
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootView(signViewController, animated: true)
    }
}

extension SettingSecessionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: SettingTableCell.self)
        cell.configure(contentLabel: "회원탈퇴", isHiddenNextImage: true)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*삭제
         1. 알럿 띄어줘서 한번 물어보고 (0)
         2.유저데이터 받아와서 언스크라이브에 넣고
         3.유저 데이터 삭제
         */
        showCustomAlert(alertType: .canCancel, titleText: "회원탈퇴", messageText: "회원 탈퇴시에 구매대역등 데이터가 삭제되며 환불 되지 않습니다.\n정말 회원 탈퇴 하시겠습니다?", confirmButtonText: "탈퇴하기", comfrimAction: {
            self.withdrawUser()
        })
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
