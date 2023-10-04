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
    
    weak var myPageDelegate: MyPageDelegate?
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: .insetGrouped)
        configTableView()
        attribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configTableView() {
        backgroundColor = .picoLightGray
        dataSource = self
        delegate = self
        addShadow(offset: CGSize(width: 5, height: 5), color: .black, opacity: 0.07, radius: 5.0)
        layer.masksToBounds = true
    }
    
    private func attribute() {
        self.register(MyPageCollectionTableCell.self, forCellReuseIdentifier: Identifier.TableCell.myPageCollectionTableCell)
        self.register(MyPageMatchingTableCell.self, forCellReuseIdentifier: Identifier.TableCell.myPageMatchingTableCell)
        self.register(MyPageDefaultTableCell.self, forCellReuseIdentifier: Identifier.TableCell.myPageDefaultTableCell)
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
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.TableCell.myPageCollectionTableCell, for: indexPath) as? MyPageCollectionTableCell else { return UITableViewCell() }
            cell.delegate = myPageDelegate
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.TableCell.myPageMatchingTableCell, for: indexPath) as? MyPageMatchingTableCell else { return UITableViewCell() }
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.TableCell.myPageDefaultTableCell, for: indexPath) as? MyPageDefaultTableCell else { return UITableViewCell() }
            cell.configure(imageName: "person", title: "상담원 연결")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
        return 90
        case 1:
        return 110
        default:
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
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
