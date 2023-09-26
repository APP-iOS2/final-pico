//
//  MailListTableViewCell.swift
//  Pico
//
//  Created by 양성혜 on 2023/09/25.
//

import UIKit

final class MailListTableViewCell: UITableViewCell {
    
    static let identifier = "MailListTableViewCell"
    
    private let userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        return stackView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.picoSubTitleFont
        label.textColor = .picoFontBlack
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let message: UILabel = {
        let label = UILabel()
        label.font = UIFont.picoDescriptionFont
        label.textColor = .picoFontBlack
        return label
    }()
    
    private let mbtiLabel = UILabel()
    
    private let dateStackView = UIStackView()
    
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
    
    private
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
       
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addViews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addViews() {
        
        [nameLabel, message, mbtiLabel].forEach {
            infoStackView.addSubview($0)
        }
        
        [dateLabel, newLabel].forEach {
            dateStackView.addSubview($0)
        }
        
        [userImage, infoStackView, dateStackView].forEach {
            contentView.addSubview($0)
        }
    }
    
    func makeConstraints() {
        
        userImage.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView).inset(5)
            make.leading.equalTo(contentView).offset(10)
            make.centerY.equalToSuperview()
            make.width.equalTo(contentView.snp.height).inset(5)
        }
        
        infoStackView.snp.makeConstraints { make in
            make.top.bottom.equalTo(userImage)
            make.leading.equalTo(userImage.snp.trailing).offset(10)
            make.trailing.equalTo(contentView).inset(80)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(infoStackView).offset(10)
            make.leading.equalTo(infoStackView)
        }
        
        mbtiLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.top)
            make.leading.equalTo(nameLabel.snp.trailing).offset(5)
            make.trailing.equalTo(infoStackView.snp.trailing)
        }
        
        message.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(infoStackView)
        }
        
        dateStackView.snp.makeConstraints { make in
            make.top.bottom.equalTo(nameLabel)
            make.trailing.equalTo(contentView.snp.trailing).inset(10)
            make.width.equalTo(50)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(dateStackView)
        }
        
        newLabel.snp.makeConstraints { make in
            make.top.equalTo(message.snp.top)
            make.leading.trailing.equalTo(dateStackView)
        }
    }
    
    func getData(imageString: String, nameText: String, mbti: String, message: String, date: String, new: Bool) {
        if let imageURL = URL(string: imageString) {
            userImage.load(url: imageURL)
        }
        nameLabel.text = nameText
        nameLabel.sizeToFit()
        mbtiLabel.text = mbti
        self.message.text = message
        dateLabel.text = date
        if new {
            newLabel.text = "new"
        }
    }
    
}
