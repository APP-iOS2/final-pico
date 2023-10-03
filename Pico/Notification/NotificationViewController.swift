//
//  NotificationViewController.swift
//  Pico
//
//  Created by 방유빈 on 2023/09/26.
//

import UIKit
import SnapKit

final class NotificationViewController: UIViewController {
    struct DummyNoti {
        let name: String
        let age: Int
        let imageUrl: String
        let notiType: NotiType
        var title: String {
            return "\(name), \(age)"
        }
    }
    
    private let tableView = UITableView()
    private let notifications: [DummyNoti] = [
        DummyNoti(name: "찐 윈터", age: 21, imageUrl: "https://image5jvqbd.fmkorea.com/files/attach/new2/20211225/3655109/3113058505/4195166827/e130faca7194985e4f162b3583d52853.jpg", notiType: .like),
        DummyNoti(name: "찐 윈터라니깐여;", age: 21, imageUrl: "https://image5jvqbd.fmkorea.com/files/attach/new2/20211225/3655109/3113058505/4195166827/e130faca7194985e4f162b3583d52853.jpg", notiType: .message),
        DummyNoti(name: "풍리나", age: 35, imageUrl: "https://flexible.img.hani.co.kr/flexible/normal/640/441/imgdb/original/2023/0525/20230525501996.jpg", notiType: .like)
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configViewController()
        addViews()
        makeConstraints()
        configTableView()
    }
    
    private func configViewController() {
        navigationItem.title = "알림"
        view.backgroundColor = .systemBackground
    }
    
    private func configTableView() {
        tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: Identifier.TableCell.notiTableCell)
        tableView.delegate = self
        tableView.dataSource = self
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
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.TableCell.notiTableCell, for: indexPath) as? NotificationTableViewCell else {
            return UITableViewCell()
        }
        cell.configData(imageUrl: notifications[indexPath.row].imageUrl, title: notifications[indexPath.row].title, type: notifications[indexPath.row].notiType)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
