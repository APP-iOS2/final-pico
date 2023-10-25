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
        label.textAlignment = .left
        return label
    }()
    
    private let createDateLabel: UILabel = {
        let label = UILabel()
        label.font = .picoDescriptionFont
        label.textColor = .picoFontGray
        label.textAlignment = .left
        label.isHidden = true
        return label
    }()
    
    private let mbtiLabel: MBTILabelView = MBTILabelView(mbti: nil, scale: .small)
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = .picoContentFont
        label.textAlignment = .left
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
        mbtiLabel.isHidden = false
        mbtiLabel.setMbti(mbti: nil)
        iconImageView.image = UIImage()
        nameLabel.text = ""
        contentLabel.text = ""
    }
    
    private func setData(imageUrl: String, nickName: String, age: Int, mbti: MBTIType) {
        guard let url = URL(string: imageUrl) else { return }
        profileImageView.kf.indicatorType = .custom(indicator: CustomIndicator(cycleSize: .small))
        profileImageView.kf.setImage(with: url)
        nameLabel.text = "\(nickName), \(age)"
        mbtiLabel.setMbti(mbti: mbti)
        mbtiLabel.isHidden = false
    }
    /// 유저리스트 config
    func configData(imageUrl: String, nickName: String, age: Int, mbti: MBTIType, createdDate: Double) {
        setData(imageUrl: imageUrl, nickName: nickName, age: age, mbti: mbti)
        iconImageView.image = UIImage()
        contentLabel.text = "가입일자 \(createdDate.toString(dateSeparator: .dot))"
        contentLabel.font = .picoDescriptionFont
        contentLabel.textColor = .picoFontGray
    }
    /// 신고, 차단, 좋아요기록 config
    func configData(recordType: RecordType, imageUrl: String, nickName: String, age: Int, mbti: MBTIType, createdDate: Double, reportReason: String = "") {
        setData(imageUrl: imageUrl, nickName: nickName, age: age, mbti: mbti)
        iconImageView.image = UIImage(systemName: recordType.iconSystemImageName)
        iconImageView.tintColor = recordType.iconColor
        if recordType == .report {
            contentLabel.text = "\(recordType.content) (\(reportReason))"
        } else {
            contentLabel.text = "\(recordType.content)"
        }
        createDateLabel.isHidden = false
        createDateLabel.text = createdDate.timeAgoSinceDate()
    }
    /// 결제기록 config
    func configData(recordType: RecordType, payment: Payment.PaymentInfo) {
        iconImageView.image = UIImage(systemName: recordType.iconSystemImageName)
        iconImageView.tintColor = recordType.iconColor
        mbtiLabel.isHidden = true
        if payment.price != 0 {
            nameLabel.text = "+\(payment.purchaseChuCount.formattedSeparator())츄"
            profileImageView.image = UIImage(named: "AppIcon")
            contentLabel.text = "\(payment.price.formattedSeparator())\(recordType.content)"
        } else {
            nameLabel.text = "\(payment.purchaseChuCount.formattedSeparator())츄"
            profileImageView.image = UIImage(named: "AppIcon_gray")
            contentLabel.text = "\(payment.paymentType.koreaName)에서 사용"
        }
        createDateLabel.isHidden = false
        createDateLabel.text = payment.purchasedDate.timeAgoSinceDate()
    }
    /// 신고목록 config
    func configData(recordType: RecordType, report: AdminReport) {
        guard let url = URL(string: report.imageURL) else { return }
        profileImageView.kf.indicatorType = .custom(indicator: CustomIndicator(cycleSize: .small))
        profileImageView.kf.setImage(with: url)
        mbtiLabel.setMbti(mbti: nil)
        mbtiLabel.isHidden = true
        iconImageView.image = UIImage(systemName: recordType.iconSystemImageName)
        iconImageView.tintColor = recordType.iconColor
        
        nameLabel.text = "피신고자: \(report.reportedNickname), \(report.age)"
        contentLabel.text = "신고자: \(report.reportNickname) (\(report.reason))"
        createDateLabel.isHidden = false
        createDateLabel.text = report.createdDate.timeAgoSinceDate()
    }
}

extension AdminUserTableViewCell {
    
    private func addViews() {
        contentView.addSubview([profileImageView, iconImageView, labelView])
        labelView.addSubview([nameLabel, mbtiLabel, contentLabel, createDateLabel])
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
        
        mbtiLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(10)
            make.centerY.equalTo(nameLabel)
            make.height.equalTo(mbtiLabel.frame.size.height)
            make.width.equalTo(mbtiLabel.frame.size.width)
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
