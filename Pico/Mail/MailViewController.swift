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
    
    private var mailTypeButtons: [UIButton] = []
    private var mailType: MailType = .receive // 받기
    
    private let mailText: UILabel = {
        let label = UILabel()
        label.text = "Mail"
        label.font = UIFont.picoTitleFont
        label.textColor = .picoFontBlack
        return label
    }()
    
    private let buttonStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        return stackView
    }()
    
    private let receiveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .picoAlphaBlue
        button.setTitle("받은 쪽지", for: .normal)
        button.titleLabel?.font = .picoDescriptionFont
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.setTitleColor(.white, for: .normal)
        button.isSelected = true
        return button
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .picoGray
        button.setTitle("보낸 쪽지", for: .normal)
        button.titleLabel?.font = .picoDescriptionFont
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.setTitleColor(.picoBetaBlue, for: .normal)
        return button
    }()
    
    private let mailListTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(MailListTableViewCell.self, forCellReuseIdentifier: Identifier.TableCell.mailTableCell)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configTableView()
        configMailTypeButtons()
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
    
    private func configMailTypeButtons() {
        sendButton.addTarget(self, action: #selector(tappedMailTypeButton), for: .touchUpInside)
        receiveButton.addTarget(self, action: #selector(tappedMailTypeButton), for: .touchUpInside)
    }
    
    private func addViews() {
        view.addSubview(mailText)
        
        [receiveButton, sendButton].forEach { item in
            mailTypeButtons.append(item)
            buttonStack.addArrangedSubview(item)
        }
        
        view.addSubview(buttonStack)
        
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
        
        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(mailText.snp.bottom).offset(10)
            make.leading.equalTo(safeArea.snp.leading).offset(20)
        }
        
        sendButton.snp.makeConstraints { make in
            make.width.equalTo(60)
        }
        
        receiveButton.snp.makeConstraints { make in
            make.width.equalTo(60)
        }
        
        viewModel.mailIsEmpty
            .subscribe(onNext: { [weak self] isEmpty in
                if isEmpty {
                    self?.emptyView.view.snp.makeConstraints { make in
                        make.edges.equalTo(safeArea)
                    }
                } else {
                    self?.mailListTableView.snp.makeConstraints { make in
                        make.top.equalTo(self?.buttonStack.snp.bottom ?? UIStackView()).offset(10)
                        make.leading.trailing.bottom.equalTo(safeArea)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    @objc func tappedMailTypeButton(_ sender: UIButton) {
        for button in mailTypeButtons {
            button.isSelected = (button == sender)
            guard let text = sender.titleLabel?.text else { return }
            switch button.isSelected {
            case true:
                sender.backgroundColor = .picoAlphaBlue
                sender.setTitleColor(.white, for: .normal)
                mailType = MailType(rawValue: text) ?? .receive
            case false:
                button.backgroundColor = .picoGray
                button.setTitleColor(.picoBetaBlue, for: .normal)
            }
        }
        configTableviewDatasource()
        mailListTableView.reloadData()
    }
}

// MARK: - MailTableView+Rx
extension MailViewController {
    private func configTableviewDatasource() {
        
        self.mailListTableView.delegate = nil
        self.mailListTableView.dataSource = nil
        
        if mailType == .receive {
            viewModel.mailRecieveList
                .bind(to: mailListTableView.rx.items(cellIdentifier: Identifier.TableCell.mailTableCell, cellType: MailListTableViewCell.self)) { _, item, cell in
                    cell.getData(senderUser: item)
                }
                .disposed(by: disposeBag)
        } else {
            viewModel.mailSendList
                .bind(to: mailListTableView.rx.items(cellIdentifier: Identifier.TableCell.mailTableCell, cellType: MailListTableViewCell.self)) { _, item, cell in
                    cell.getData(senderUser: item)
                }
                .disposed(by: disposeBag)
        }
    }
    
    private func configTableviewDelegate() {
        mailListTableView.rx.modelSelected(DummyMailUsers.self)
            .subscribe(onNext: { item in
                let mailReceiveView = MailReceiveViewController()
                mailReceiveView.modalPresentationStyle = .formSheet
                mailReceiveView.getReceiver(mailSender: item)
                self.present(mailReceiveView, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}

// 밥먹고 해야할 일
// - 시작시 버튼 받은 메일로 뜨도록
// - 받는 값 수정에 따른 보이는 값 변경 ( 유빈님 like 코드 확인 )
