//
//  MailListTableViewCell.swift
//  Pico
//
//  Created by 양성혜 on 2023/09/25.
//

import UIKit
import SnapKit
import RxSwift

final class MailListTableViewCell: UITableViewCell {
    
    private let viewModel = MailViewModel()
    private let disposeBag = DisposeBag()
    
    private var mailInfo: Mail.MailInfo?
    
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
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func getData(senderUser: Mail.MailInfo, type: MailType) {
        self.mailInfo = senderUser
        
        viewModel.getUser(userId: senderUser.sendedUserId) {
            guard (self.viewModel.user != nil) else { return }
            guard let url = URL(string: self.viewModel.user?.imageURLs[0] ?? "") else { return }
            self.userImage.kf.setImage(with: url)
            self.nameLabel.text = self.viewModel.user?.nickName
            self.nameLabel.sizeToFit()
            self.mbtiLabelView.setMbti(mbti: self.viewModel.user?.mbti ?? .infj)
            self.message.text = senderUser.message
            self.dateLabel.text = senderUser.sendedDate
            
            if type == .receive {
                if !senderUser.isReading {
                    self.newLabel.text = "new"
                }
            }
        }
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
}
