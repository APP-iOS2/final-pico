//
//  MailListTableViewCell.swift
//  Pico
//
//  Created by 양성혜 on 2023/09/25.
//

import UIKit

final class MailListTableViewCell: UITableViewCell {
    
    private let userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        return imageView
    }()
    
    private let nameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        return stackView
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .leading
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
    
    private let mbtiLabelView: MBTILabelView = MBTILabelView(mbti: .infj)
    
    private let dateStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .fill
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
       
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addViews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addViews() {
        
        [nameLabel, mbtiLabelView].forEach {
            nameStackView.addArrangedSubview($0)
        }
        
        [nameStackView, message].forEach {
            infoStackView.addArrangedSubview($0)
        }
        
        [dateLabel, newLabel].forEach {
            dateStackView.addArrangedSubview($0)
        }
        
        [userImage, infoStackView, dateStackView].forEach {
            contentView.addSubview($0)
        }
    }
    
    func makeConstraints() {
        
        userImage.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(15)
            make.leading.equalTo(contentView).offset(10)
            make.width.height.equalTo(contentView.snp.height).inset(15)
        }
        
        nameStackView.snp.makeConstraints { make in
            make.top.equalTo(infoStackView)
            make.leading.equalTo(userImage.snp.trailing).offset(15)
        }
        
        infoStackView.snp.makeConstraints { make in
            make.top.equalTo(userImage).offset(10)
            make.leading.equalTo(nameStackView)
            make.trailing.equalTo(contentView).inset(70)
            make.bottom.equalTo(userImage).offset(-10)
        }
        
        dateStackView.snp.makeConstraints { make in
            make.top.bottom.equalTo(infoStackView)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
            make.width.equalTo(50)
        }
    }
    
    func getData(imageString: String, nameText: String, mbti: String, message: String, date: String, new: Bool) {
        if let imageURL = URL(string: imageString) {
            userImage.load(url: imageURL)
        }
        nameLabel.text = nameText
        nameLabel.sizeToFit()
        self.message.text = message
        dateLabel.text = date
        if new {
            newLabel.text = "new"
        }
    }
    
}
