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
        return label
    }()
    
    lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: ChattingType.receive.imageStyle))
        return imageView
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.picoDescriptionFont
        label.textColor = .gray
        label.textAlignment = .left
        return label
    }()
    
    // MARK: - MailCell +LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .clear
        addViews()
        makeConstraints()
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
    
    // MARK: - MailCell +UI
    func config(chatInfo: ChatDetail.ChatInfo) {
        
        FirestoreService.shared.searchDocumentWithEqualField(collectionId: .users, field: "id", compareWith: chatInfo.sendUserId, dataType: User.self) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let user):
                if !user.isEmpty {
                    guard let userData = user[safe: 0] else { break }
                    nameLabel.text = userData.nickName
                    guard let imageURL = userData.imageURLs[safe: 0] else { return }
                    guard let url = URL(string: imageURL) else { return }
                    userImageView.kf.indicatorType = .custom(indicator: CustomIndicator(cycleSize: .small))
                    userImageView.kf.setImage(with: url)
                } else {
                    userImageView.image = UIImage(named: "AppIcon_gray")
                    nameLabel.text = "탈퇴된 회원"
                }
            case .failure(let err):
                print(err)
            }
        }
        self.messageLabel.text = chatInfo.message
        let date = chatInfo.sendedDate.timeAgoSinceDate()
        self.dateLabel.text = date
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
