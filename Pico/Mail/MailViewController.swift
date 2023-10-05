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

final class MailViewController: BaseViewController {
    
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
        configTableView()
        addViews()
        makeConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mailListTableView.reloadData()
    }
    
    private func configTableView() {
        mailListTableView.rowHeight = 100
        configTableviewDatasource()
        configTableviewDelegate()
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

// MARK: - MailTableView+Rx
extension MailViewController {
    private func configTableviewDatasource() {
        viewModel.mailList
            .bind(to: mailListTableView.rx.items(cellIdentifier: Identifier.TableCell.mailTableCell, cellType: MailListTableViewCell.self)) { _, item, cell in
                cell.getData(senderUser: item)
            }
            .disposed(by: disposeBag)
    }
    
    private func configTableviewDelegate() {
        mailListTableView.rx.modelSelected(DummyMailUsers.self)
            .subscribe(onNext: { item in
                if self.mailCheck {
                    let mailReceiveView = MailReceiveViewController()
                    mailReceiveView.modalPresentationStyle = .formSheet
                    mailReceiveView.getReceiver(mailSender: item)
                    self.present(mailReceiveView, animated: true, completion: nil)
                    
                } else {
                    let mailSendView = MailSendViewController()
                    mailSendView.modalPresentationStyle = .formSheet
                    mailSendView.getReceiver(mailReceiver: item)
                    self.present(mailSendView, animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)
    }
}
