//
//  MailListTableViewCell.swift
//  Pico
//
//  Created by 양성혜 on 2023/09/25.
//

import UIKit

final class MailListTableViewCell: UITableViewCell {
    
    let userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        return imageView
    }()
    
    private let infoStackView = UIStackView()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        return label
    }()
    
    let message: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    let mbtiLabel = UILabel()
    
    private let dateStackView = UIStackView()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.textColor = .black
        return label
    }()
    
    let newLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 5)
        label.textColor = .red
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
       
        addSubViews()
        makeConstraints()
       
    }
    
    func addSubViews() {
        
        [userImage, infoStackView, dateStackView].forEach {
            contentView.addSubview($0)
        }
        
        [nameLabel, message, mbtiLabel].forEach {
            infoStackView.addSubview($0)
        }
        
        [dateLabel, newLabel].forEach {
            dateStackView.addSubview($0)
        }
        
    }
    
    func makeConstraints() {
        
        userImage.snp.makeConstraints { make in
            make.leading.equalTo(contentView)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(70.0)
        }
        
        infoStackView.snp.makeConstraints { make in
            make.top.bottom.equalTo(userImage).offset(10)
            make.leading.equalTo(userImage.snp.trailing).offset(10)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(infoStackView)
        }
        
        mbtiLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.top)
            make.leading.equalTo(nameLabel.snp.trailing).offset(5)
        }
        
        message.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.leading.equalTo(nameLabel.snp.leading)
        }
        
        dateStackView.snp.makeConstraints { make in
                make.top.equalTo(nameLabel.snp.top)
                make.trailing.equalTo(contentView.snp.trailing)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.trailing.equalTo(dateStackView)
        }
        
        newLabel.snp.makeConstraints { make in
            make.top.equalTo(message.snp.top)
            make.trailing.equalTo(dateLabel.snp.trailing)
        }
        
    }
   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
