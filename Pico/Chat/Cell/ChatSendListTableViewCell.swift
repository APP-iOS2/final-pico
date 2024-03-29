//
//  ChatSendListTableViewCell.swift
//  Pico
//
//  Created by 양성혜 on 2023/12/21.
//

import UIKit
import SnapKit
import RxSwift

final class ChatSendListTableViewCell: UITableViewCell {
    
    private let chatView = UIView()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.picoContentFont
        label.textColor = .white
        label.textAlignment = .right
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.setLineSpacing(spacing: 10)
        return label
    }()
    
    private var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: ChatType.send.imageStyle))
        return imageView
    }()
    
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
        self.contentView.backgroundColor = .clear
        addViews()
        makeConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        messageLabel.text = ""
        dateLabel.text = ""
    }
    
    // MARK: - MailCell +UI
    func config(chatInfo: ChatDetail.ChatInfo) {
        self.messageLabel.text = chatInfo.message
        let date = chatInfo.sendedDate.timeAgoSinceDate()
        self.dateLabel.text = date
    }
    
    private func addViews() {
        contentView.addSubview([chatView])
        chatView.addSubview([dateLabel, backgroundImageView, messageLabel])
    }
    
    private func makeConstraints() {
        chatView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(chatView).offset(20)
            make.trailing.equalTo(chatView).offset(-20)
            make.bottom.equalTo(-10)
        }
        
        backgroundImageView.snp.makeConstraints { make in
            make.top.equalTo(messageLabel).offset(-10)
            make.leading.equalTo(messageLabel).offset(-10)
            make.trailing.equalTo(messageLabel).offset(15)
            make.bottom.equalTo(messageLabel).offset(10)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(10)
            make.trailing.equalTo(backgroundImageView.snp.leading).offset(-10)
            make.bottom.equalTo(backgroundImageView.snp.bottom)
        }
    }
}
