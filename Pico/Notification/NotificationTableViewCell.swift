//
//  NotificationTableViewCell.swift
//  Pico
//
//  Created by 방유빈 on 2023/09/26.
//

import UIKit
import SnapKit

enum NotiType {
    case like
    case message
}
class NotificationTableViewCell: UITableViewCell {
    private var notiType: NotiType = .like
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "AppIcon")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "heart.fill")
        imageView.tintColor = .picoBlue
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "찐 윈터임, 21"
        label.font = .picoSubTitleFont
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.text = "님이 좋아요를 누르셨습니다."
        return label
    }()
    
    private let labelView: UIView = {
        let view = UIView()
        return view
    }()
    
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
    
    func configData(imageUrl: String, title: String, type: NotiType) {
        guard let url = URL(string: imageUrl) else { return }
        notiType = type
        profileImageView.load(url: url)
        iconImageView.image = notiType == .like ? UIImage(systemName: "heart.fill") : UIImage(systemName: "message.fill")
        nameLabel.text = title
        contentLabel.text = notiType == .like ? "님이 좋아요를 누르셨습니다." : "님이 쪽지를 보냈습니다."
    }
    
    private func addViews() {
        [profileImageView, iconImageView, labelView].forEach { item in
            addSubview(item)
        }
        
        [nameLabel, contentLabel].forEach { item in
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
            make.leading.trailing.equalToSuperview()
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.leading.trailing.equalTo(nameLabel)
            make.bottom.equalToSuperview()
        }
    }
}
