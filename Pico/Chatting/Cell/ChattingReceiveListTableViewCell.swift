//
//  ChattingReceiveListTableViewCell.swift
//  Pico
//
//  Created by 양성혜 on 2023/12/16.
//

import UIKit
import SnapKit
import RxSwift

final class ChattingReceiveListTableViewCell: UITableViewCell {
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.picoDescriptionFont
        label.textColor = .picoFontBlack
        return label
    }()
    
    private let chatView = UIView()
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.picoContentFont
        label.textColor = .picoFontBlack
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.setLineSpacing(spacing: 10)
        return label
    }()
    
    lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: ChatType.receive.imageStyle))
        return imageView
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.picoDescriptionFont
        label.textColor = .gray
        label.textAlignment = .left
        return label
    }()
    
    weak var chattingDetailDelegate: ChattingDetailDelegate?
    private var opponentId: String = ""
    
    // MARK: - MailCell +LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .clear
        addViews()
        makeConstraints()
        configGesture()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        userImageView.image = UIImage(named: "AppIcon")
        nameLabel.text = ""
        messageLabel.text = ""
        dateLabel.text = ""
    }
    
    private func configGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedImageView))
        userImageView.addGestureRecognizer(tapGesture)
        userImageView.isUserInteractionEnabled = true
    }
    
    @objc private func tappedImageView(_ sender: UITapGestureRecognizer) {
        getUserData { [weak self] user in
            guard let self else { return }
            chattingDetailDelegate?.tappedImageView(user: user)
        }
    }
    
    private func getUserData(completion: @escaping (User) -> ()) {
        FirestoreService.shared.searchDocumentWithEqualField(collectionId: .users, field: "id", compareWith: opponentId, dataType: User.self) { result in
            switch result {
            case .success(let user):
                if !user.isEmpty {
                    guard let userData = user[safe: 0] else { break }
                    completion(userData)
                }
            case .failure(let err):
                print(err)
            }
        }
    }
   
    // MARK: - MailCell +UI
    func config(chatInfo: ChatDetail.ChatInfo, opponentName: String, opponentImageURLString: String) {
        opponentId = chatInfo.sendUserId
        nameLabel.text = opponentName
        
        let url = URL(string: opponentImageURLString) ?? URL(string: Defaults.userImageURLString)
        
        userImageView.kf.indicatorType = .custom(indicator: CustomIndicator(cycleSize: .small))
        userImageView.kf.setImage(with: url)
        
        messageLabel.text = chatInfo.message
        let date = chatInfo.sendedDate.timeAgoSinceDate()
        dateLabel.text = date
    }
    
    private func addViews() {
        contentView.addSubview([chatView])
        chatView.addSubview([userImageView, nameLabel, backgroundImageView, messageLabel, dateLabel])
    }
    
    private func makeConstraints() {
        chatView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        userImageView.snp.makeConstraints { make in
            make.top.leading.equalTo(chatView).offset(10)
            make.width.height.equalTo(50)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(userImageView)
            make.leading.equalTo(userImageView.snp.trailing).offset(10)
            make.trailing.equalTo(-10)
            make.height.equalTo(15)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(15)
            make.leading.equalTo(nameLabel).offset(10)
            make.bottom.equalTo(-10)
        }
        
        backgroundImageView.snp.makeConstraints { make in
            make.top.equalTo(messageLabel).offset(-10)
            make.leading.equalTo(messageLabel).offset(-15)
            make.trailing.equalTo(messageLabel).offset(10)
            make.bottom.equalTo(messageLabel).offset(10)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(backgroundImageView.snp.trailing).offset(10)
            make.trailing.equalTo(-10)
            make.bottom.equalTo(backgroundImageView.snp.bottom)
        }
    }
}
