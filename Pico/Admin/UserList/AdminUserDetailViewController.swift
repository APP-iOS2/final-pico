//
//  AdminUserDetailViewController.swift
//  Pico
//
//  Created by 최하늘 on 10/12/23.
//

import UIKit
import SnapKit

final class AdminUserDetailViewController: UIViewController {
    
    private let tableView: UITableView = UITableView()
    
    private var user: User!
    
    init(user: User) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.configBackgroundColor()
        addViews()
        makeConstraints()
        configTableView()
    }
    
    private func configTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cell: UserImageTableCell.self)
        tableView.rowHeight = UserImageTableCellConstraint.height
    }
}

extension AdminUserDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: UserImageTableCell.self)
        cell.config(images: user.imageURLs)
        cell.selectionStyle = .none
        return cell
    }
}

extension AdminUserDetailViewController {
    private func addViews() {
        view.addSubview(tableView)
    }
    
    private func makeConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
