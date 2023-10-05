//
//  MailSendViewController.swift
//  Pico
//
//  Created by 양성혜 on 2023/09/26.
//

import UIKit
import SnapKit

final class MailSendViewController: UIViewController {
    
    private let navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar()
        navigationBar.barTintColor = .systemBackground
        return navigationBar
    }()
    
    private let navItem: UINavigationItem = {
        let navigationItem = UINavigationItem(title: "쪽지 보내기")
        return navigationItem
    }()
    
    private let receiverStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 10
        return stackView
    }()
    
    private let receiverLabel: UILabel = {
        let label = UILabel()
        label.text = "To."
        label.textAlignment = .center
        label.font = .picoContentBoldFont
        label.textColor = .picoFontBlack
        return label
    }()
    
    private let receiverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let receiverNameLabel: UILabel = {
        let label = UILabel()
        label.font = .picoContentBoldFont
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
    
    private let textViewPlaceHolder = "메시지를 입력하세요"
    
    private lazy var messageView: UITextView = {
        
        let textView: UITextView = UITextView()
        textView.text = textViewPlaceHolder
        textView.font = .picoContentFont
        textView.textColor = .lightGray
        textView.backgroundColor = .clear
        textView.delegate = self
        return textView
    }()
    
    private lazy var remainCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0 / 300"
        label.font = .picoContentFont
        label.textColor = .picoFontBlack
        label.textAlignment = .right
        return label
    }()
    
    private let sendButton: UIButton = {
        let button = CommonButton(type: .custom)
        button.setTitle("보내기", for: .normal)
        button.addTarget(nil, action: #selector(tappedSendButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        addViews()
        makeConstraints()
        configBackButton()
        configNavigationBarItem()
        tappedDismissKeyboard()
    }
    
    override func viewDidLayoutSubviews() {
        setCircleImageView(imageView: receiverImageView)
    }
    
    func configNavigationBarItem() {
        navigationBar.shadowImage = UIImage()
        navigationBar.setItems([navItem], animated: true)
    }
    
    private func addViews() {
        
        [receiverLabel, receiverImageView, receiverNameLabel].forEach { views in
            receiverStack.addArrangedSubview(views)
        }
        
        [messageView, remainCountLabel].forEach { views in
            contentView.addArrangedSubview(views)
        }
        
        view.addSubview(navigationBar)
        
        [receiverStack, contentView, sendButton].forEach { views in
            view.addSubview(views)
        }
    }
    
    private func makeConstraints() {
        
        let safeArea = view.safeAreaLayoutGuide
        
        navigationBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeArea)
        }
        
        receiverStack.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom).offset(20)
            make.leading.equalTo(navigationBar).offset(20)
            make.trailing.equalTo(navigationBar).offset(-20)
            make.height.equalTo(50)
        }
        
        receiverLabel.snp.makeConstraints { make in
            make.width.equalTo(35)
        }
        
        receiverImageView.snp.makeConstraints { make in
            make.width.height.equalTo(50)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(receiverStack.snp.bottom).offset(20)
            make.leading.trailing.equalTo(receiverStack)
            make.bottom.equalTo(sendButton.snp.bottom).offset(-80)
        }
        
        sendButton.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.bottom.equalTo(safeArea).offset(-30)
            make.height.equalTo(50)
        }
    }
    
    func getReceiver(image: String, name: String) {
        if let imageURL = URL(string: image) {
            receiverImageView.load(url: imageURL)
        }
        receiverNameLabel.text = name
    }
    
    @objc private func tappedSendButton(_ sender: UIButton) {
        tappedButtonAnimation(sender)
        dismiss(animated: true)
        print("send")
    }
    
    private func updateCountLabel(characterCount: Int) {
        remainCountLabel.text = "\(characterCount)/300"
    }
}

extension MailSendViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == textViewPlaceHolder {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = .lightGray
            updateCountLabel(characterCount: 0)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let inputString = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let oldString = textView.text, let newRange = Range(range, in: oldString) else { return true }
        let newString = oldString.replacingCharacters(in: newRange, with: inputString).trimmingCharacters(in: .whitespacesAndNewlines)
        
        let characterCount = newString.count
        guard characterCount <= 300 else { return false }
        updateCountLabel(characterCount: characterCount)
        
        return true
    }
}
