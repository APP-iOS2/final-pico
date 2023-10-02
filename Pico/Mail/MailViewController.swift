//
//  MailViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import SnapKit

final class MailViewController: BaseViewController {
    
    private let emptyView = EmptyViewController(type: .message)
    
    private let mailText: UILabel = {
        let label = UILabel()
        label.text = "쪽지"
        label.font = UIFont.picoContentBoldFont
        label.textColor = .picoFontBlack
        return label
    }()
    
    private let mailListTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(MailListTableViewCell.self, forCellReuseIdentifier: Identifier.TableCell.mailTableCell)
        return tableView
    }()
    
    private let dataCount: Int = 1
    private let mailCheck: Bool = true // 받은 상태일경우
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            addChild(emptyView)
            view.addSubview(emptyView.view)
            emptyView.didMove(toParent: self)
        } else {
            view.addSubview(mailListTableView)
        }
    }
    
    func makeConstraints() {
        
        let safeArea = view.safeAreaLayoutGuide
        
        mailText.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(20)
            make.leading.trailing.equalTo(safeArea).offset(30)
        }
        
        if dataCount < 1 {
            emptyView.view.snp.makeConstraints { make in
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.TableCell.mailTableCell, for: indexPath) as? MailListTableViewCell else { return UITableViewCell() }
        cell.getData(imageString: "https://cdn.topstarnews.net/news/photo/201902/580120_256309_4334.jpg", nameText: "강아지는월월", mbti: "ISTP", message: "하이룽", date: "9.26", new: true)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if mailCheck {
            let mailReceiveView = MailReceiveViewController()
            mailReceiveView.modalPresentationStyle = .formSheet
            mailReceiveView.getReceiver(image: "https://cdn.topstarnews.net/news/photo/201902/580120_256309_4334.jpg", name: "강아지는월월", message: "하이룽 방가룽", date: "9/25")
            self.present(mailReceiveView, animated: true, completion: nil)
        } else {
            let mailSendView = MailSendViewController()
            mailSendView.modalPresentationStyle = .formSheet
            mailSendView.getReceiver(image: "https://cdn.topstarnews.net/news/photo/201902/580120_256309_4334.jpg", name: "강아지는월월")
            self.present(mailSendView, animated: true, completion: nil)
        }
    }
}
