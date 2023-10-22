//
//  NotificationTableViewCell.swift
//  Pico
//
//  Created by 방유빈 on 2023/09/26.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import Kingfisher

final class NotificationTableViewCell: UITableViewCell {
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let iconImageView: UIImageView = UIImageView()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .picoSubTitleFont
        return label
    }()
    
    private let createDateLabel: UILabel = {
        let label = UILabel()
        label.font = .picoDescriptionFont
        label.textColor = .picoFontGray
        label.isHidden = true
        return label
    }()
    
    private let mbtiLabel: MBTILabelView = MBTILabelView(mbti: nil, scale: .small)
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = .picoContentFont
        return label
    }()
    private let labelView: UIView = UIView()
    
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
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2.0
        profileImageView.clipsToBounds = true
        self.setNeedsUpdateConstraints()
    }
    
    override func prepareForReuse() {
        profileImageView.image = UIImage(named: "AppIcon")
        mbtiLabel.setMbti(mbti: nil)
        iconImageView.image = UIImage()
        nameLabel.text = ""
        contentLabel.text = ""
    }
    
    func configData(notitype: NotiType, imageUrl: String, nickName: String, age: Int, mbti: MBTIType, date: Double) {
        guard let url = URL(string: imageUrl) else { return }
        profileImageView.kf.indicatorType = .custom(indicator: CustomIndicator(cycleSize: .small))
        profileImageView.kf.setImage(with: url)
        iconImageView.image = UIImage(systemName: notitype.iconSystemImageName)
        iconImageView.tintColor = notitype.iconColor
        contentLabel.text = notitype.content
        nameLabel.text = "\(nickName), \(age)"
        mbtiLabel.setMbti(mbti: mbti)
        createDateLabel.isHidden = false
        createDateLabel.text = date.timeAgoSinceDate()
    }
    
    private func addViews() {
        contentView.addSubview([profileImageView, iconImageView, labelView])
        labelView.addSubview([nameLabel, mbtiLabel, contentLabel, createDateLabel])
    }
    
    private func makeConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(10)
            make.width.height.equalTo(60)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.bottom.equalTo(profileImageView)
            make.trailing.equalTo(profileImageView).offset(3)
        }
        
        labelView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
            make.centerY.equalTo(profileImageView)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
        }
        
        mbtiLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(10)
            make.centerY.equalTo(nameLabel)
            make.height.equalTo(mbtiLabel.frame.size.height)
            make.width.equalTo(mbtiLabel.frame.size.width)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.leading.equalTo(nameLabel)
            make.trailing.equalToSuperview()
        }
        
        createDateLabel.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(5)
            make.leading.equalTo(nameLabel)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
