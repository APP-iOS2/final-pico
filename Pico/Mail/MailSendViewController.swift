//
//  MailSendViewController.swift
//  Pico
//
//  Created by 양성혜 on 2023/09/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MailSendViewController: UIViewController {
    
    private let viewModel = MailSendModel()
    private let disposeBag = DisposeBag()
    
    private var receiver: User = User(mbti: .infj, phoneNumber: "", gender: .etc, birth: "", nickName: "", location: Location(address: "서울시 강남구", latitude: 10, longitude: 10), imageURLs: [], createdDate: 0, subInfo: nil, reports: nil, blocks: nil, chuCount: 0, isSubscribe: false)
    private var isMessageView = true
    
    private let navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar()
        navigationBar.barTintColor = .systemBackground
        return navigationBar
    }()
    
    private let navItem: UINavigationItem = {
        let navigationItem = UINavigationItem(title: "쪽지 보내기")
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
    
    private let toLabel: UILabel = {
        let label = UILabel()
        label.text = "To."
        label.font = .picoContentBoldFont
        label.textColor = .picoFontBlack
        return label
    }()
    
    private let receiverStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        return stackView
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
    
    private let mbtiLabelView: MBTILabelView = MBTILabelView(mbti: .infj, scale: .small)
    
    private let contentView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.backgroundColor = .picoLightGray
        stackView.clipsToBounds = true
        stackView.layer.cornerRadius = 20
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
        return stackView
    }()
    
    private let messageView: UITextView = {
        let textView: UITextView = UITextView()
        textView.text = "메시지를 입력하세요"
        textView.font = .picoContentFont
        textView.textColor = .picoFontGray
        textView.backgroundColor = .clear
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
        button.backgroundColor = .picoGray
        return button
    }()
    // MARK: - MailSend +LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.configBackgroundColor()
        view.tappedDismissKeyboard()
        configNavigationBarItem()
        addViews()
        makeConstraints()
        changeTextView()
        configSendButton()
    }
    
    override func viewDidLayoutSubviews() {
        receiverImageView.setCircleImageView()
    }
    // MARK: - MailSend +UI
    private func addViews() {
        receiverStack.addArrangedSubview( [receiverNameLabel, mbtiLabelView])
        contentView.addArrangedSubview( [messageView, remainCountLabel])
        
        view.addSubview(navigationBar)
        view.addSubview([toLabel, receiverImageView, receiverStack, contentView, sendButton])
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        navigationBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeArea)
        }
        
        toLabel.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom).offset(20)
            make.leading.equalTo(safeArea).offset(20)
            make.trailing.equalTo(safeArea).offset(-20)
        }
        
        receiverImageView.snp.makeConstraints { make in
            make.top.equalTo(toLabel.snp.bottom).offset(10)
            make.leading.equalTo(toLabel)
            make.width.height.equalTo(50)
        }
        
        receiverStack.snp.makeConstraints { make in
            make.top.equalTo(receiverImageView).offset(12)
            make.leading.equalTo(receiverImageView.snp.trailing).offset(10)
        }
        
        mbtiLabelView.snp.makeConstraints { make in
            make.width.equalTo(mbtiLabelView.frame.size.width)
            make.height.equalTo(mbtiLabelView.frame.size.height)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(receiverImageView.snp.bottom).offset(20)
            make.leading.equalTo(receiverImageView)
            make.trailing.equalTo(toLabel)
            make.bottom.equalTo(sendButton.snp.bottom).offset(-80)
        }
        
        sendButton.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.bottom.equalTo(safeArea).offset(-30)
            make.height.equalTo(50)
        }
    }
    // MARK: - MailSend +Config
    func configData(userId: String, atMessageView: Bool ) {
        isMessageView = atMessageView
        
        viewModel.getUser(userId: userId) {
            if let user = self.viewModel.user {
                self.receiver = user
                guard let url = URL(string: user.imageURLs[0]) else { return }
                self.receiverImageView.kf.indicatorType = .custom(indicator: CustomIndicator(cycleSize: .small))
                self.receiverImageView.kf.setImage(with: url)
                self.receiverNameLabel.text = user.nickName
                self.receiverNameLabel.sizeToFit()
                self.mbtiLabelView.setMbti(mbti: user.mbti)
            }
        }
    }
    
    private func configNavigationBarItem() {
        navItem.leftBarButtonItem = leftBarButton
        navigationBar.shadowImage = UIImage()
        navigationBar.setItems([navItem], animated: true)
    }
    
    private func configSendButton() {
        sendButton.rx.tap
            .bind { [weak self] _ in
                guard let self = self  else { return }
                self.sendButton.tappedAnimation()
                if let text = self.messageView.text {
                    // sender: 로그인한 사람, recevie 받는 사람
                    self.viewModel.saveMailData(receiveUser: receiver, message: text, type: .message)
                    if isMessageView {
                        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    } else {
                        dismiss(animated: true)
                        
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    // MARK: - MailSend +objc
    @objc func tappedBackzButton() {
        dismiss(animated: true)
    }
}
// MARK: - MailSend +textView
extension MailSendViewController {
    private func changeTextView() {
        let textViewPlaceHolder = "메시지를 입력하세요"
        
        messageView.rx.didBeginEditing
            .bind { [weak self] _ in
                guard let self = self else { return }
                if self.messageView.text == textViewPlaceHolder {
                    self.messageView.text = nil
                    self.messageView.textColor = .black
                }
            }
            .disposed(by: disposeBag)
        
        messageView.rx.didEndEditing
            .bind { [weak self] _ in
                guard let self = self else { return }
                if let text = self.messageView.text {
                    if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        self.messageView.text = textViewPlaceHolder
                        self.messageView.textColor = .picoFontGray
                        self.updateCountLabel(characterCount: 0)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        messageView.rx.text
            .orEmpty
            .subscribe(onNext: { changedText in
                if changedText != textViewPlaceHolder {
                    let characterCount = changedText.count
                    if characterCount <= 300 {
                        self.updateCountLabel(characterCount: characterCount)
                    }
                    self.sendButton.backgroundColor = .picoBlue
                } else {
                    self.updateCountLabel(characterCount: 0)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func updateCountLabel(characterCount: Int) {
        remainCountLabel.text = "\(characterCount)/300"
    }
}
