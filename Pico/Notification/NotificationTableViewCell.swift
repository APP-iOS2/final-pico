//
//  NotificationTableViewCell.swift
//  Pico
//
//  Created by 방유빈 on 2023/09/26.
//

import UIKit
import SnapKit

class NotificationTableViewCell: UITableViewCell {
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "AppIcon")
        imageView.contentMode = .scaleAspectFit
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
    
    override func layoutSubviews() {
        print("layout : \(profileImageView.frame.width)")
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2.0
        profileImageView.clipsToBounds = true
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addViews()
        makeConstraints()
        configImage()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configImage() {
        print("config : \(profileImageView.frame.width)")
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2.0
        profileImageView.clipsToBounds = true
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
        
        labelView.snp.makeConstraints { make in
            make.top.trailing.bottom.equalToSuperview()
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(labelView).offset(10)
            make.leading.trailing.equalToSuperview()
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.leading.trailing.equalTo(nameLabel)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
}
