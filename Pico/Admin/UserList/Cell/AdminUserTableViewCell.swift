//
//  AdminUserTableViewCell.swift
//  Pico
//
//  Created by 최하늘 on 10/21/23.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import Kingfisher

final class AdminUserTableViewCell: UITableViewCell {
    
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
    
    private let mbitLabel: MBTILabelView = MBTILabelView(mbti: .enfp, scale: .small)
    
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
        iconImageView.image = UIImage()
        nameLabel.text = ""
        contentLabel.text = ""
    }
    
    private func setData(imageUrl: String, nickName: String, age: Int, mbti: MBTIType) {
        guard let url = URL(string: imageUrl) else { return }
        profileImageView.kf.indicatorType = .custom(indicator: CustomIndicator(cycleSize: .small))
        profileImageView.kf.setImage(with: url)
        nameLabel.text = "\(nickName), \(age)"
        mbitLabel.setMbti(mbti: mbti)
    }
    
    func configData(imageUrl: String, nickName: String, age: Int, mbti: MBTIType, createdDate: Double) {
        setData(imageUrl: imageUrl, nickName: nickName, age: age, mbti: mbti)
        iconImageView.image = UIImage()
        contentLabel.text = "가입일자 \(createdDate.toString(dateSeparator: .dot))"
        contentLabel.font = .picoDescriptionFont
        contentLabel.textColor = .picoFontGray
    }
    
    func configData(recordType: RecordType, imageUrl: String, nickName: String, age: Int, mbti: MBTIType, createdDate: Double) {
        setData(imageUrl: imageUrl, nickName: nickName, age: age, mbti: mbti)
        iconImageView.image = UIImage(systemName: recordType.iconSystemImageName)
        iconImageView.tintColor = recordType.iconColor
        contentLabel.text = recordType.content
        createDateLabel.isHidden = false
        createDateLabel.text = createdDate.timeAgoSinceDate()
    }
    
    func configData(recordType: RecordType, payment: Payment.PaymentInfo) {
        updateConstraint()
        profileImageView.image = UIImage(named: "AppIcon")
        iconImageView.image = UIImage(systemName: recordType.iconSystemImageName)
        iconImageView.tintColor = recordType.iconColor
        mbitLabel.isHidden = true
        nameLabel.text = "\(payment.purchaseChuCount)츄"
        nameLabel.textAlignment = .right
        if payment.price != 0 {
            contentLabel.text = "\(payment.price.formattedSeparator())\(recordType.content)"
        } else {
            contentLabel.text = ""
        }
        contentLabel.textAlignment = .right
        createDateLabel.isHidden = false
        createDateLabel.text = payment.purchasedDate.timeAgoSinceDate()
        createDateLabel.textAlignment = .right
    }
    
    private func updateConstraint() {
        nameLabel.snp.remakeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(10)
        }
    }
}

extension AdminUserTableViewCell {
    
    private func addViews() {
        contentView.addSubview([profileImageView, iconImageView, labelView])
        labelView.addSubview([nameLabel, mbitLabel, contentLabel, createDateLabel])
    }
    
    private func makeConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalTo(10)
            make.bottom.equalToSuperview().offset(-10)
            make.width.equalTo(profileImageView.snp.height)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.bottom.equalTo(profileImageView)
            make.trailing.equalTo(profileImageView).offset(3)
        }
        
        labelView.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalTo(profileImageView)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
        }
        
        mbitLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(10)
            make.centerY.equalTo(nameLabel)
            make.height.equalTo(mbitLabel.frame.size.height)
            make.width.equalTo(mbitLabel.frame.size.width)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.leading.equalTo(nameLabel)
            make.trailing.equalTo(-10)
        }
        
        createDateLabel.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(5)
            make.leading.equalTo(nameLabel).offset(2)
            make.trailing.equalTo(contentLabel.snp.trailing)
            make.bottom.equalToSuperview()
        }
    }
}
