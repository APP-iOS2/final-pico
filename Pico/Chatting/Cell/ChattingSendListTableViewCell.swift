//
//  ChattingSendListTableViewCell.swift
//  Pico
//
//  Created by 양성혜 on 2023/12/21.
//

import UIKit
import SnapKit
import RxSwift

final class ChattingSendListTableViewCell: UITableViewCell {
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.picoContentFont
        label.textColor = .picoFontBlack
        label.textAlignment = .right
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: ChattingType.send.imageStyle))
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
    func config(chatting: Chatting.ChattingInfo) {
        self.messageLabel.text = chatting.message
        let date = chatting.sendedDate.timeAgoSinceDate()
        self.dateLabel.text = date
    }
    
    private func addViews() {
        contentView.addSubview([dateLabel, backgroundImageView, messageLabel])
    }
    
    private func makeConstraints() {
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(10)
            make.trailing.equalTo(contentView).offset(-30)
        }
        
        backgroundImageView.snp.makeConstraints { make in
            make.top.bottom.equalTo(messageLabel)
            make.leading.equalTo(messageLabel).offset(-10)
            make.trailing.equalTo(messageLabel).offset(15)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.trailing.equalTo(backgroundImageView.snp.leading).offset(-10)
            make.bottom.equalTo(backgroundImageView)
            make.width.equalTo(60)
        }
    }
}
