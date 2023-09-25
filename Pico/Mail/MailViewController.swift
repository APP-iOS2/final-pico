//
//  MailViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import SnapKit

final class MailViewController: UIViewController {
    
    private let mailText: UILabel = {
        let label = UILabel()
        label.text = "쪽지"
        label.font = UIFont.picoSubTitleFont
        label.textColor = .picoFontBlack
        return label
    }()
    
    private let mailListTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(MailListTableViewCell.self, forCellReuseIdentifier: "MailListTableViewCell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        configTableView()
        addViews()
        makeConstraints()
    }
    
    private func configTableView() {
        mailListTableView.dataSource = self
        mailListTableView.rowHeight = 100
        mailListTableView.delegate = self
    }
    
    func addViews() {
        view.addSubview(mailText)
        view.addSubview(mailListTableView)
    }
    
    func makeConstraints() {
        
        let safeArea = view.safeAreaLayoutGuide
        
        mailText.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(10)
            make.leading.trailing.equalTo(safeArea).offset(20)
        }
        
        mailListTableView.snp.makeConstraints { make in
            make.top.equalTo(mailText.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalTo(safeArea).offset(20)
        }
    }
}

extension MailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MailListTableViewCell", for: indexPath) as? MailListTableViewCell else { return UITableViewCell() }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("select \(indexPath.row)")
    }
}
