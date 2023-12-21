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
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let textStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 10
        return stackView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.picoContentBoldFont
        label.textColor = .picoFontBlack
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.picoDescriptionFont
        label.textColor = .picoFontBlack
        return label
    }()
    
    private let backgroundImageView: UIImageView = UIImageView()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.picoDescriptionFont
        label.textColor = .gray
        label.textAlignment = .right
        return label
    }()
    // MARK: - MailCell +LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addViews()
        makeConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.layer.cornerRadius = userImageView.frame.width / 2.0
        userImageView.clipsToBounds = true
        self.setNeedsUpdateConstraints()
    }
    
    override func prepareForReuse() {
        userImageView.image = UIImage(named: "AppIcon")
        nameLabel.text = ""
        messageLabel.text = ""
        backgroundImageView.image = UIImage()
        dateLabel.text = ""
    }
    
    // MARK: - MailCell +UI
    func config(chatting: Chatting.ChattingInfo) {
        
        FirestoreService.shared.searchDocumentWithEqualField(collectionId: .users, field: "id", compareWith: chatting.sendUserId, dataType: User.self) { [weak self] result in
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
                    backgroundImageView.image = UIImage(systemName: ChattingType.receive.imageStyle)
                } else {
                    userImageView.image = UIImage(named: "AppIcon_gray")
                    nameLabel.text = "탈퇴된 회원"
                }
            case .failure(let err):
                print(err)
            }
        }
        
        nameLabel.sizeToFit()
        self.messageLabel.text = chatting.message
        
        let date = chatting.sendedDate.timeAgoSinceDate()
        self.dateLabel.text = date
    }
    
    private func addViews() {
        textStack.addArrangedSubview([nameLabel, messageLabel, backgroundImageView])
        contentView.addSubview([userImageView, textStack, dateLabel])
    }
    
    private func makeConstraints() {
        userImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(10)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(self)
            make.width.height.equalTo(60)
        }
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalTo((textLabel?.snp.edges)!)
        }
        
        textStack.snp.makeConstraints { make in
            make.leading.equalTo(userImageView.snp.trailing).offset(10)
            make.height.equalTo(70)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.trailing.equalTo(contentView.snp.trailing).offset(-30)
            make.bottom.equalTo(backgroundImageView)
            make.width.equalTo(60)
        }
    }
}
