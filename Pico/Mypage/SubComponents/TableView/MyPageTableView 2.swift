//
//  MyPageTableView.swift
//  Pico
//
//  Created by 김민기 on 2023/09/26.
//

import RxSwift
import RxCocoa
import SnapKit
import UIKit

final class MyPageTableView: UITableView {
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: .insetGrouped)
        configTableView()
        attribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configTableView() {
        self.backgroundColor = .picoGray
        self.dataSource = self
        self.delegate = self
    }
    
    private func attribute() {
        self.register(MyPageFirstTableCell.self, forCellReuseIdentifier: "MyPageFirstTableCell")
        self.register(MyPageSecondTableCell.self, forCellReuseIdentifier: "MyPageSecondTableCell")
        self.register(MyPageDefaultTableCell.self, forCellReuseIdentifier: "MyPageDefaultTableCell")
    }
}

extension MyPageTableView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyPageFirstTableCell", for: indexPath) as? MyPageFirstTableCell else { return UITableViewCell() }

            return cell
        } else if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyPageSecondTableCell", for: indexPath) as? MyPageSecondTableCell else { return UITableViewCell() }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyPageDefaultTableCell", for: indexPath) as? MyPageDefaultTableCell else { return UITableViewCell() }
            cell.configure(imageName: "person", title: "상담원과 연결")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 90
        } else if indexPath.section == 1 {
            return 110
        } else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20.0
        } else {
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
