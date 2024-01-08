//
//  RoomListTableViewCell.swift
//  Pico
//
//  Created by 양성혜 on 2023/12/20.
//

import UIKit
import SnapKit
import RxSwift

final class RoomListTableViewCell: UITableViewCell {
    
    private let disposeBag = DisposeBag()
    private let viewModel = RoomViewModel()
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "AppIcon")
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30
        return imageView
    }()
    
    private let userStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 10
        return stackView
    }()
    
    private let nameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
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
    
    private let mbtiLabelView: MBTILabelView = MBTILabelView(mbti: nil, scale: .small)
    
    private let dateStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.picoDescriptionFont
        label.textColor = .gray
        label.textAlignment = .right
        return label
    }()
    
    private let newLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.picoDescriptionFont2
        label.textColor = .systemRed
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
    
    override func prepareForReuse() {
        userImageView.image = UIImage(named: "AppIcon")
        mbtiLabelView.setMbti(mbti: nil)
        mbtiLabelView.isHidden = true
        nameLabel.text = ""
        messageLabel.text = ""
        dateLabel.text = ""
        newLabel.text = ""
    }
    
    // MARK: - MailCell +UI
    func config(receiveUser: Room.RoomInfo) -> String {
        
        let userId: String = receiveUser.opponentId
        var nickName: String = ""
        FirestoreService.shared.searchDocumentWithEqualField(collectionId: .users, field: "id", compareWith: userId, dataType: User.self) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let user):
                if !user.isEmpty {
                    guard let userData = user[safe: 0] else { break }
                    nameLabel.text = userData.nickName
                    nickName = userData.nickName
                    mbtiLabelView.isHidden = false
                    mbtiLabelView.setMbti(mbti: userData.mbti)
                    guard let imageURL = userData.imageURLs[safe: 0] else { return }
                    guard let url = URL(string: imageURL) else { return }
                    userImageView.kf.indicatorType = .custom(indicator: CustomIndicator(cycleSize: .small))
                    userImageView.kf.setImage(with: url)
                } else {
                    userImageView.image = UIImage(named: "AppIcon_gray")
                    nameLabel.text = "탈퇴된 회원"
                    mbtiLabelView.isHidden = true
                    mbtiLabelView.setMbti(mbti: nil)
                }
            case .failure(let err):
                print(err)
            }
        }
        
        nameLabel.sizeToFit()
        self.messageLabel.text = receiveUser.lastMessage
        
        let date = receiveUser.sendedDate.timeAgoSinceDate()
        self.dateLabel.text = date
        
        return nickName
    }
    
    private func addViews() {
        nameStackView.addArrangedSubview([nameLabel, mbtiLabelView])
        userStackView.addArrangedSubview([nameStackView, messageLabel])
        dateStackView.addArrangedSubview([dateLabel, newLabel])
        
        contentView.addSubview([userImageView, userStackView, dateStackView])
    }
    
    private func makeConstraints() {
        userImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(10)
            make.leading.equalTo(contentView).offset(20)
            make.width.height.equalTo(60)
        }
        
        nameStackView.snp.makeConstraints { make in
            make.top.equalTo(userStackView)
            make.leading.equalTo(userImageView.snp.trailing).offset(10)
        }
        
        mbtiLabelView.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel)
            make.height.equalTo(mbtiLabelView.frame.size.height)
            make.width.equalTo(mbtiLabelView.frame.size.width)
        }
        
        userStackView.snp.makeConstraints { make in
            make.top.equalTo(userImageView).offset(5)
            make.leading.equalTo(nameStackView)
            make.trailing.equalTo(contentView).offset(-70)
            make.bottom.equalTo(userImageView).offset(-10)
        }
        
        dateStackView.snp.makeConstraints { make in
            make.top.bottom.equalTo(userStackView)
            make.trailing.equalTo(contentView.snp.trailing).offset(-30)
            make.width.equalTo(60)
        }
    }
}
