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
        label.font = UIFont.picoDescriptionFont
        label.textColor = .picoFontBlack
        return label
    }()
    
    private let backgroundImageView: UIImageView = UIImageView()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.picoDescriptionFont
        label.textColor = .gray
        label.textAlignment = .left
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
    
    override func prepareForReuse() {
        messageLabel.text = ""
        backgroundImageView.image = UIImage()
        dateLabel.text = ""
    }
    
    // MARK: - MailCell +UI
    func config(chatting: Chatting.ChattingInfo) {
        
        FirestoreService.shared.searchDocumentWithEqualField(collectionId: .users, field: "id", compareWith: chatting.receiveUserId, dataType: User.self) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let user):
                if !user.isEmpty {
                    guard user[safe: 0] != nil else { break }
                    backgroundImageView.image = UIImage(systemName: ChattingType.receive.imageStyle)
                }
            case .failure(let err):
                print(err)
            }
        }
        
        self.messageLabel.text = chatting.message
        
        let date = chatting.sendedDate.timeAgoSinceDate()
        self.dateLabel.text = date
    }
    
    private func addViews() {
        contentView.addSubview([messageLabel, backgroundImageView, dateLabel])
    }
    
    private func makeConstraints() {
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(10)
            make.leading.equalTo(self)
            make.trailing.equalTo(contentView).offset(-20)
            make.height.equalTo(70)
        }
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalTo(messageLabel.snp.edges)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.trailing.equalTo(contentView.snp.trailing).offset(-30)
            make.bottom.equalTo(backgroundImageView)
            make.width.equalTo(60)
        }
    }
}
