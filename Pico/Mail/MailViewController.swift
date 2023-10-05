//
//  MailViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

final class MailViewController: UIViewController {
    
    private let emptyView = EmptyViewController(type: .message)
    private let viewModel = MailViewModel()
    private var disposeBag = DisposeBag()
    
    private let mailText: UILabel = {
        let label = UILabel()
        label.text = "Mail"
        label.font = UIFont.picoTitleFont
        label.textColor = .picoFontBlack
        return label
    }()
    
    private let mailListTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(MailListTableViewCell.self, forCellReuseIdentifier: Identifier.TableCell.mailTableCell)
        return tableView
    }()
    
    private let mailCheck: Bool = true // 받은 상태일경우
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configLogoBarItem()
        configViewController()
        configTableView()
        addViews()
        makeConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mailListTableView.reloadData()
    }
    
    private func configViewController() {
        view.backgroundColor = .systemBackground
    }
    
    private func configTableView() {
        mailListTableView.rowHeight = 80
    }
    
    private func addViews() {
        view.addSubview(mailText)
        
        viewModel.mailIsEmpty
            .subscribe(onNext: { [weak self] isEmpty in
                if isEmpty {
                    self?.view.addSubview(self?.emptyView.view ?? UIView())
                    self?.emptyView.didMove(toParent: self)
                } else {
                    self?.view.addSubview(self?.mailListTableView ?? UITableView())
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        mailText.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(10)
            make.leading.equalTo(safeArea).offset(20)
            make.trailing.equalTo(safeArea).offset(-30)
        }
        
        viewModel.mailIsEmpty
            .subscribe(onNext: { [weak self] isEmpty in
                if isEmpty {
                    self?.emptyView.view.snp.makeConstraints { make in
                        make.edges.equalTo(safeArea)
                    }
                } else {
                    self?.mailListTableView.snp.makeConstraints { make in
                        make.top.equalTo(self?.mailText.snp.bottom ?? UILabel()).offset(10)
                        make.leading.bottom.equalTo(safeArea).offset(20)
                        make.trailing.equalTo(safeArea).offset(-20)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}

extension MailViewController {
    
}

/*
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
 */
