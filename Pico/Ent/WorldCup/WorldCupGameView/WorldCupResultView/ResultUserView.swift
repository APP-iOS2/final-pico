//
//  ResultUserView.swift
//  Pico
//
//  Created by 오영석 on 2023/10/04.
//

import UIKit

final class ResultUserView: UIView {
    
    lazy var mbtiLabel: MBTILabelView = MBTILabelView(mbti: .esfj, scale: .small)

    lazy var userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var userNickname: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.picoSubTitleFont
        label.numberOfLines = 0
        return label
    }()
    
    lazy var userAge: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.picoButtonFont
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        addViews()
        makeConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews() {
        addSubview([mbtiLabel, userImage, userNickname, userAge])
    }
    
    private func makeConstraints() {
        let padding: CGFloat = 10
        let half: CGFloat = 0.5
        
        mbtiLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(padding)
            make.leading.equalTo(self.snp.leading).offset(padding)
            make.trailing.equalTo(self.snp.trailing).offset(-padding)
            make.width.equalTo(mbtiLabel.frame.size.width)
            make.height.equalTo(mbtiLabel.frame.size.height)
        }

        userImage.snp.makeConstraints { make in
            make.top.equalTo(mbtiLabel.snp.bottom).offset(padding * half)
            make.leading.equalTo(self.snp.leading).offset(padding)
            make.trailing.equalTo(self.snp.trailing).offset(padding)
            make.width.equalTo(self.snp.width).offset(-padding * 2)
            make.height.equalTo(self.snp.width).offset(-padding * 2)
        }

        userNickname.snp.makeConstraints { make in
            make.top.equalTo(userImage.snp.bottom).offset(padding * half)
            make.centerX.equalTo(self.snp.centerX)
        }
        
        userAge.snp.makeConstraints { make in
            make.top.equalTo(userNickname.snp.bottom)
            make.centerX.equalTo(self.snp.centerX)
        }
    }
}
