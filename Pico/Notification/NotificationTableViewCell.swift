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

class NotificationTableViewCell: UITableViewCell {
    
    var notiType: NotiType = .like
    
    var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "heart.fill")
        imageView.tintColor = .picoBlue
        return imageView
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .picoSubTitleFont
        return label
    }()
    
    let mbitLabel: MBTILabelView = MBTILabelView(mbti: .enfp, scale: .small)
    
    let contentLabel: UILabel = UILabel()
    private let labelView: UIView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addViews()
        makeConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2.0
        profileImageView.clipsToBounds = true
        self.setNeedsUpdateConstraints()
    }
    
    private func addViews() {
        [profileImageView, iconImageView, labelView].forEach { item in
            contentView.addSubview(item)
        }
        
        [nameLabel, mbitLabel, contentLabel].forEach { item in
            labelView.addSubview(item)
        }
    }
    
    private func makeConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.width.equalTo(profileImageView.snp.height)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.bottom.equalTo(profileImageView)
            make.trailing.equalTo(profileImageView).offset(3)
        }
        
        labelView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
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
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

extension NotificationTableViewCell {
    func configData(imageUrl: String, nickName: String, age: Int, mbti: MBTIType, createdDate: String) {
        guard let url = URL(string: imageUrl) else { return }
        profileImageView.load(url: url)
        iconImageView.image = UIImage()
        nameLabel.text = "\(nickName), \(age)"
        mbitLabel.setMbti(mbti: mbti)
        contentLabel.text = createdDate
    }
    
    override func prepareForReuse() {
        profileImageView.image = UIImage(named: "AppIcon")
        iconImageView.image = UIImage()
        nameLabel.text = ""
        contentLabel.text = ""
    }
}
