//
//  MailListTableViewCell.swift
//  Pico
//
//  Created by 양성혜 on 2023/09/25.
//

import UIKit
import SnapKit

final class MailListTableViewCell: UITableViewCell {
    
    private let userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 40
        return imageView
    }()
    
    private let nameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
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
    
    private let mbtiLabelView: MBTILabelView = MBTILabelView(mbti: .infj, scale: .small)
    
    private let dateStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addViews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews() {
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
    
    private func makeConstraints() {
        userImage.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(10)
            make.leading.equalTo(contentView).offset(10)
            make.width.height.equalTo(80)
        }
        
        nameStackView.snp.makeConstraints { make in
            make.top.equalTo(infoStackView)
            make.leading.equalTo(userImage.snp.trailing).offset(15)
            
        }
        
        mbtiLabelView.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel)
            make.height.equalTo(mbtiLabelView.frame.size.height)
            make.width.equalTo(mbtiLabelView.frame.size.width)
        }
        
        infoStackView.snp.makeConstraints { make in
            make.top.equalTo(userImage).offset(10)
            make.leading.equalTo(nameStackView)
            make.trailing.equalTo(contentView).offset(-70)
            make.bottom.equalTo(userImage).offset(-10)
        }
        
        dateStackView.snp.makeConstraints { make in
            make.top.bottom.equalTo(infoStackView)
            make.trailing.equalTo(contentView.snp.trailing).offset(-10)
            make.width.equalTo(50)
        }
    }
    
    // 질문! 받아와서 보여줘야하는 경우 코드를 cell 뷰 파일에 두는 것이 맞나요? 또한 rx 처리를 해줘야하나요?
    func getData(senderUser: DummyMailUsers) {
        if let imageURL = URL(string: senderUser.messages.imageUrl) {
            userImage.load(url: imageURL)
        }
        nameLabel.text = senderUser.messages.oppenentName
        nameLabel.sizeToFit()
        self.message.text = senderUser.messages.message
        dateLabel.text = senderUser.messages.sendedDate
        if !senderUser.messages.isReading {
            newLabel.text = "new"
        }
    }
}
