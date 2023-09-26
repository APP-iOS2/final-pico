//
//  NotificationViewController.swift
//  Pico
//
//  Created by 방유빈 on 2023/09/26.
//

import UIKit
import SnapKit

class NotificationViewController: UIViewController {
    private let tableView = UITableView()
    let name = ["AAA, 24", "BBB, 20", "CCC, 21"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        makeConstraints()
        configTableView()
    }
    
    private func configTableView() {
        tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: Identifier.TableCell.notiTableCell)
        tableView.delegate = self
        tableView.dataSource = self
<<<<<<< HEAD
=======

>>>>>>> a2f6174 (feat: 알림 테이블뷰 디자인(진행중))
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

extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return name.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.TableCell.notiTableCell, for: indexPath) as? NotificationTableViewCell else {
            return UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
