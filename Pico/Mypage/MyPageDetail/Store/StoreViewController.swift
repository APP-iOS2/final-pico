//
//  StoreViewController.swift
//  Pico
//
//  Created by 김민기 on 2023/09/26.
//

import UIKit
import SnapKit

final class StoreViewController: UIViewController {
    
    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.register(cell: StoreTableCell.self)
        view.backgroundColor = .clear
        view.addShadow(offset: CGSize(width: 10, height: 10), opacity: 0.07, radius: 5)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        configTableView()
        addViews()
        makeConstraints()
    }
    
    private func configView() {
        title = "Store"
        view.configBackgroundColor()
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

extension StoreViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: StoreTableCell.self)
        switch indexPath.section {
        case 0: cell.configure(count: "50", price: "5,500", discount: nil)
        case 1: cell.configure(count: "100", price: "11,000", discount: nil)
        case 2: cell.configure(count: "500", price: "50,000", discount: "10")
        case 3: cell.configure(count: "1000", price: "88,000", discount: "20")
        default: break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20.0
        } else {
            return 10.0
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
