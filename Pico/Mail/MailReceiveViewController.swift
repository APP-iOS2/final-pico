//
//  MailReceiveViewController.swift
//  Pico
//
//  Created by 양성혜 on 2023/09/26.
//

import UIKit
import SnapKit

final class MailReceiveViewController: UIViewController {
    
    private let navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar()
        navigationBar.barTintColor = .systemBackground
        return navigationBar
    }()
    
    private let navItem: UINavigationItem = {
        let navigationItem = UINavigationItem(title: "받은 쪽지")
        return navigationItem
    }()
    
    private let rightBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "paperplane.fill"), style: .plain, target: nil, action: #selector(tappedNavigationButton))
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
    
    private lazy var messageView: UITextView = {
        let textView: UITextView = UITextView()
        textView.font = .picoContentFont
        textView.textColor = .picoFontBlack
        textView.backgroundColor = .clear
        textView.isEditable = false
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        addViews()
        makeConstraints()
        configNavigationBarItem()
        tappedDismissKeyboard()
    }
    
    override func viewDidLayoutSubviews() {
        setCircleImageView(imageView: senderImageView)
    }
    
    func configNavigationBarItem() {
        navItem.rightBarButtonItem = rightBarButton
        navigationBar.shadowImage = UIImage()
        navigationBar.setItems([navItem], animated: true)
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
            make.bottom.equalTo(safeArea.snp.bottom).inset(50)
        }
    }
    
    func getReceiver(image: String, name: String, message: String, date: String) {
        if let imageURL = URL(string: image) {
            senderImageView.load(url: imageURL)
        }
        senderNameLabel.text = name
        sendDateLabel.text = date
        messageView.text = message
    }
    
    @objc func tappedNavigationButton() {
        let mailSendView = MailSendViewController()
        mailSendView.modalPresentationStyle = .formSheet
        mailSendView.getReceiver(image: "https://cdn.topstarnews.net/news/photo/201902/580120_256309_4334.jpg", name: "강아지는월월")
        self.present(mailSendView, animated: true, completion: nil)
    }
}
