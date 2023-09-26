//
//  MailViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import SnapKit

final class MailViewController: UIViewController {
    
    let emptyView: MailEmptyView = MailEmptyView(frame: CGRect(x: 0, y: 0, width: Screen.height, height: Screen.width))
    
    private let mailText: UILabel = {
        let label = UILabel()
        label.text = "쪽지"
        label.font = UIFont.picoSubTitleFont
        label.textColor = .picoFontBlack
        return label
    }()
    
    private let mailListTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(MailListTableViewCell.self, forCellReuseIdentifier: MailListTableViewCell.identifier)
        return tableView
    }()
    
    private let dataCount: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        configLogoBarItem()
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
        
        if dataCount < 1 {
            view.addSubview(emptyView)
        } else {
            view.addSubview(mailListTableView)
        }
    }
    
    func makeConstraints() {
        
        let safeArea = view.safeAreaLayoutGuide
        
        mailText.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(10)
            make.leading.trailing.equalTo(safeArea).offset(30)
        }
        
        if dataCount < 1 {
            emptyView.snp.makeConstraints { make in
                make.edges.equalTo(safeArea)
            }
        } else {
            mailListTableView.snp.makeConstraints { make in
                make.top.equalTo(mailText.snp.bottom).offset(10)
                make.leading.trailing.bottom.equalTo(safeArea).offset(20)
            }
        }
    }
}

extension MailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MailListTableViewCell.identifier, for: indexPath) as? MailListTableViewCell else { return UITableViewCell() }
        cell.getData(imageString: "https://cdn.topstarnews.net/news/photo/201902/580120_256309_4334.jpg", nameText: "강아지는월월", mbti: "ISTP", message: "하이룽", date: "9.26", new: true)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let mailSendView = MailSendViewController()
        mailSendView.modalPresentationStyle = .pageSheet
        self.present(mailSendView, animated: true, completion: nil)
    }
}
