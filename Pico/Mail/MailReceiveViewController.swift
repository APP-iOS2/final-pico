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
    
    private let viewModel = MailReceiveViewModel()
    private let disposeBag = DisposeBag()
    private var mailUser: Mail.MailInfo = Mail.MailInfo(sendedUserId: "", receivedUserId: "", mailType: .receive, message: "", sendedDate: 0, isReading: false)
    
    weak var mailReceiveDelegate: MailReceiveDelegate?
    weak var mailSendDelegate: MailSendDelegate?
    
    private let navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar()
        navigationBar.barTintColor = .white
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
        barButtonItem.action = #selector(tappedBackButton)
        return barButtonItem
    }()
    
    private let rightBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem()
        barButtonItem.image = UIImage(systemName: "paperplane.fill")
        barButtonItem.tintColor = .picoBlue
        return barButtonItem
    }()
    
    private let userStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 15
        return stackView
    }()
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let userInfoStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
        return stackView
    }()
    
    private let userNameStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        return stackView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .picoContentBoldFont
        label.textColor = .picoFontBlack
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let mbtiLabelView: MBTILabelView = MBTILabelView(mbti: nil, scale: .small)
    
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
        stackView.clipsToBounds = true
        stackView.layer.cornerRadius = 20
        stackView.backgroundColor = .picoLightGray
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
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
    
    // MARK: - MailReceive +LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.configBackgroundColor()
        view.tappedDismissKeyboard()
        addViews()
        makeConstraints()
        configNavigationBarItem()
        configSenderStack()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tappedNavigationButton()
    }
    
    override func viewDidLayoutSubviews() {
        userImageView.setCircleImageView()
    }
    
    // MARK: - MailReceive +UI
    private func addViews() {
        userNameStack.addArrangedSubview([userNameLabel, mbtiLabelView])
        userInfoStack.addArrangedSubview( [userNameStack, sendDateLabel])
        userStack.addArrangedSubview([userImageView, userInfoStack])
        contentView.addArrangedSubview(messageView)
        
        view.addSubview(navigationBar)
        view.addSubview([userStack, contentView])
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        navigationBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeArea)
        }
        
        mbtiLabelView.snp.makeConstraints { make in
            make.width.equalTo(mbtiLabelView.frame.size.width)
            make.height.equalTo(mbtiLabelView.frame.size.height)
        }
        
        userStack.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom).offset(20)
            make.leading.equalTo(navigationBar).offset(20)
            make.height.equalTo(50)
        }
        
        userImageView.snp.makeConstraints { make in
            make.width.height.equalTo(50)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(userStack.snp.bottom).offset(20)
            make.leading.equalTo(userStack)
            make.trailing.equalTo(safeArea).offset(-20)
            make.bottom.equalTo(safeArea.snp.bottom).offset(-50)
        }
    }
    
    private func tappedNavigationButton() {
        rightBarButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                
                let mailSendView = MailSendViewController()
                mailSendView.configData(userId: mailUser.mailType == .receive ? mailUser.sendedUserId : mailUser.receivedUserId, atMessageView: true)
                mailSendView.modalPresentationStyle = .fullScreen
                mailSendView.modalTransitionStyle = .flipHorizontal
                present(mailSendView, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
    }
    // MARK: - MailReceive + config
    func configData(mailSender: Mail.MailInfo) {
        mailUser = mailSender
        navItem.title = mailSender.mailType.typeString
        
        var userId: String
        if mailSender.mailType == .receive {
            userId = mailSender.sendedUserId
        } else {
            userId = mailSender.receivedUserId
        }
        FirestoreService.shared.searchDocumentWithEqualField(collectionId: .users, field: "id", compareWith: userId, dataType: User.self) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let user):
                if !user.isEmpty {
                    guard let userData = user[safe: 0] else { break }
                    guard let imageURL = userData.imageURLs[safe: 0] else { return }
                    guard let url = URL(string: imageURL) else { return }
                    userImageView.kf.indicatorType = .custom(indicator: CustomIndicator(cycleSize: .small))
                    userImageView.kf.setImage(with: url)
                    
                    userNameLabel.text = userData.nickName
                    mbtiLabelView.isHidden = false
                    mbtiLabelView.setMbti(mbti: userData.mbti)
                    if #available(iOS 16.0, *) {
                        rightBarButton.isHidden = false
                    }
                } else {
                    userImageView.image = UIImage(named: "AppIcon_gray")
                    
                    userNameLabel.text = "탈퇴된 회원"
                    mbtiLabelView.isHidden = true
                    mbtiLabelView.setMbti(mbti: nil)
                    
                    if #available(iOS 16.0, *) {
                        rightBarButton.isHidden = true
                    }
                }
            case .failure(let err):
                print(err)
            }
        }
        userNameLabel.sizeToFit()
        self.sendDateLabel.text = mailSender.sendedDate.toStringTime()
        self.messageView.text = mailSender.message
    }
    
    private func configNavigationBarItem() {
        navItem.leftBarButtonItem = leftBarButton
        navItem.rightBarButtonItem = rightBarButton
        navigationBar.shadowImage = UIImage()
        navigationBar.setItems([navItem], animated: true)
    }
    
    private func configSenderStack() {
        let stackTap = UITapGestureRecognizer(target: self, action: #selector(tappedSenderStack))
        userStack.addGestureRecognizer(stackTap)
    }
    
    // MARK: - MailReceive +objc
    @objc func tappedBackButton() {
        dismiss(animated: true)
    }
    
    @objc func tappedSenderStack() {
        dismiss(animated: true)
        
        var userId: String
        
        if self.mailUser.mailType == .receive {
            userId = self.mailUser.sendedUserId
        } else {
            userId = self.mailUser.receivedUserId
        }
    
        FirestoreService.shared.searchDocumentWithEqualField(collectionId: .users, field: "id", compareWith: userId, dataType: User.self) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let user):
                if !user.isEmpty {
                    guard let userData = user[safe: 0] else { break }
                    if self.mailUser.mailType == .receive {
                        mailReceiveDelegate?.pushUserDetailViewController(user: userData)
                    } else {
                        mailSendDelegate?.pushUserDetailViewController(user: userData)
                    }
                }
            case .failure(let err):
                print(err)
            }
        }
    }
}
