//
//  MailListTableViewCell.swift
//  Pico
//
//  Created by 양성혜 on 2023/09/25.
//

import UIKit
import SnapKit
import RxSwift

final class MailListTableViewCell: UITableViewCell {
    
    private let viewModel = MailViewModel()
    private let disposeBag = DisposeBag()
    
    private var mailInfo: Mail.MailInfo?
    
    private let userImage: UIImageView = {
        let imageView = UIImageView()
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
    
    private let message: UILabel = {
        let label = UILabel()
        label.font = UIFont.picoDescriptionFont
        label.textColor = .picoFontBlack
        return label
    }()
    
    private let mbtiLabelView: MBTILabelView = MBTILabelView(mbti: .infj, scale: .small)
    
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
        label.textColor = .picoFontBlack
        return label
    }()
    
    private let newLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.picoDescriptionFont
        label.textColor = .red
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
    
    // MARK: - MailCell +UI
    func getData(senderUser: Mail.MailInfo, type: MailType) {
        self.mailInfo = senderUser
        
        if senderUser.mailType == .receive {
            viewModel.getUser(userId: senderUser.sendedUserId) {
                if let user = self.viewModel.user {
                    self.configViews(user: user)
                }
            }
        } else {
            viewModel.getUser(userId: senderUser.receivedUserId) {
                if let user = self.viewModel.user {
                    self.configViews(user: user)
                }
            }
        }
        self.message.text = senderUser.message
        
        let date = senderUser.sendedDate
        let startIndex = date.index(date.startIndex, offsetBy: 5)
        let range = startIndex...
        self.dateLabel.text = "\(date[range].prefix(2)).\(date[range].suffix(2))"
        
        if type == .receive {
            if !senderUser.isReading {
                self.newLabel.text = "new"
            }
        }
    }
    
    private func addViews() {
        nameStackView.addArrangedSubview([nameLabel, mbtiLabelView])
        userStackView.addArrangedSubview([nameStackView, message])
        dateStackView.addArrangedSubview([dateLabel, newLabel])
        
        contentView.addSubview([userImage, userStackView, dateStackView])
    }
    
    private func makeConstraints() {
        userImage.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(10)
            make.leading.equalTo(contentView).offset(10)
            make.width.height.equalTo(60)
        }
        
        nameStackView.snp.makeConstraints { make in
            make.top.equalTo(userStackView)
            make.leading.equalTo(userImage.snp.trailing).offset(15)
            
        }
        
        mbtiLabelView.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel)
            make.height.equalTo(mbtiLabelView.frame.size.height)
            make.width.equalTo(mbtiLabelView.frame.size.width)
        }
        
        userStackView.snp.makeConstraints { make in
            make.top.equalTo(userImage).offset(10)
            make.leading.equalTo(nameStackView)
            make.trailing.equalTo(contentView).offset(-70)
            make.bottom.equalTo(userImage).offset(-10)
        }
        
        dateStackView.snp.makeConstraints { make in
            make.top.bottom.equalTo(userStackView)
            make.trailing.equalTo(contentView.snp.trailing).offset(-10)
            make.width.equalTo(50)
        }
    }
    
    // MARK: - MailCell +config
    private func configViews (user: User) {
        guard let url = URL(string: user.imageURLs[0]) else { return }
        userImage.kf.indicatorType = .custom(indicator: CustomIndicator(cycleSize: .small))
        userImage.kf.setImage(with: url)
        nameLabel.text = user.nickName
        nameLabel.sizeToFit()
        mbtiLabelView.setMbti(mbti: user.mbti)
    }
}
