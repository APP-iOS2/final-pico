//
//  MailReceiveViewController.swift
//  Pico
//
//  Created by 양성혜 on 2023/09/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MailReceiveViewController: UIViewController {
    
    private var viewModel: DummyMailUsers?
    private var disposeBag = DisposeBag()
    
    private let navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar()
        navigationBar.barTintColor = .systemBackground
        return navigationBar
    }()
    
    private let navItem: UINavigationItem = {
        let navigationItem = UINavigationItem(title: "받은 쪽지")
        return navigationItem
    }()
    
    private let leftBarButton: UIBarButtonItem = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let barButtonItem = UIBarButtonItem()
        barButtonItem.image = UIImage(systemName: "chevron.left", withConfiguration: imageConfig)
        barButtonItem.tintColor = .picoBlue
        barButtonItem.action = #selector(tappedBackzButton)
        return barButtonItem
    }()
    
    private let rightBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem()
        barButtonItem.image = UIImage(systemName: "paperplane.fill")
        barButtonItem.tintColor = .picoBlue
        return barButtonItem
    }()
    
    private let senderStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 20
        return stackView
    }()
    
    private let senderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let infoStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 10
        return stackView
    }()
    
    private let senderNameLabel: UILabel = {
        let label = UILabel()
        label.font = .picoContentBoldFont
        label.textColor = .picoFontBlack
        return label
    }()
    
    private let sendDateLabel: UILabel = {
        let label = UILabel()
        label.font = .picoDescriptionFont
        label.textColor = .picoFontBlack
        return label
    }()
    
    private let contentView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.backgroundColor = .picoGray
        stackView.clipsToBounds = true
        stackView.layer.cornerRadius = 20
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        return stackView
    }()
    
    private let messageView: UITextView = {
        let textView: UITextView = UITextView()
        textView.font = .picoContentFont
        textView.textColor = .picoFontBlack
        textView.backgroundColor = .clear
        textView.isEditable = false
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.configBackgroundColor()
        view.tappedDismissKeyboard()
        addViews()
        makeConstraints()
        configNavigationBarItem()
        configSenderStack()
        tappedNavigationButton()
    }
    
    override func viewDidLayoutSubviews() {
        senderImageView.setCircleImageView()
    }
    
    func getReceiver(mailSender: DummyMailUsers) {
        
        viewModel = mailSender
        navItem.title = mailSender.mailType.rawValue
        
        if let imageURL = URL(string: mailSender.messages.imageUrl) {
            senderImageView.load(url: imageURL)
        }
        senderNameLabel.text = mailSender.messages.oppenentName
        sendDateLabel.text = mailSender.messages.sendedDate
        messageView.text = mailSender.messages.message
    }
    
    private func addViews() {
        [senderNameLabel, sendDateLabel].forEach { views in
            infoStack.addArrangedSubview(views)
        }
        
        [senderImageView, infoStack].forEach { views in
            senderStack.addArrangedSubview(views)
        }
        
        [messageView].forEach { views in
            contentView.addArrangedSubview(views)
        }
        
        view.addSubview(navigationBar)
        
        [senderStack, contentView].forEach { views in
            view.addSubview(views)
        }
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        navigationBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeArea)
        }
        
        senderStack.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom).offset(20)
            make.leading.equalTo(navigationBar).offset(20)
            make.trailing.equalTo(navigationBar).offset(-20)
            make.height.equalTo(50)
        }
        
        senderImageView.snp.makeConstraints { make in
            make.width.height.equalTo(50)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(senderStack.snp.bottom).offset(20)
            make.leading.trailing.equalTo(senderStack)
            make.bottom.equalTo(safeArea.snp.bottom).offset(-50)
        }
    }
    
    private func configNavigationBarItem() {
        navItem.leftBarButtonItem = leftBarButton
        navItem.rightBarButtonItem = rightBarButton
        navigationBar.shadowImage = UIImage()
        navigationBar.setItems([navItem], animated: true)
    }
    
    private func configSenderStack() {
        let stackTap = UITapGestureRecognizer(target: self, action: #selector(tappedSenderStack))
        senderStack.addGestureRecognizer(stackTap)
    }
    
    // 질문! 단순히 화면 전환을 하는 경우에도 rx 처리를 하는 것이 맞나요?
    private func tappedNavigationButton() {
        rightBarButton.rx.tap
            .bind {
                let mailSendView = MailSendViewController()
                if let mailUser = self.viewModel {
                    mailSendView.getReceiver(mailReceiver: mailUser)
                }
                mailSendView.modalPresentationStyle = .formSheet
                mailSendView.modalTransitionStyle = .flipHorizontal
                self.present(mailSendView, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
    }
    
    @objc func tappedBackzButton() {
        dismiss(animated: true)
    }
    
    @objc func tappedSenderStack() {
        let viewController = UserDetailViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
