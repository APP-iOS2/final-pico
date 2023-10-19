//
//  WorldCupCollectionViewCell.swift
//  Pico
//
//  Created by 오영석 on 2023/09/27.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class WorldCupCollectionViewCell: UICollectionViewCell {
    
    private let disposeBag = DisposeBag()
    
    lazy var mbtiLabel: MBTILabelView = {
        let view = MBTILabelView(mbti: .esfj, scale: .small)
        return view
    }()
    
    lazy var userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
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
    
    let userInfoStackView: WorldCupUserInfoStackView = {
        let stackView = WorldCupUserInfoStackView()
        stackView.backgroundColor = .white
        return stackView
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
        [mbtiLabel, userImage, userNickname, userAge, userInfoStackView].forEach { item in
            contentView.addSubview(item)
        }
    }
    
    private func makeConstraints() {
        let padding: CGFloat = 10
        let half: CGFloat = 0.5
        
        mbtiLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(padding)
            make.leading.equalTo(contentView.snp.leading).offset(padding)
            make.trailing.equalTo(contentView.snp.trailing).offset(-padding)
            make.width.equalTo(mbtiLabel.frame.size.width)
            make.height.equalTo(mbtiLabel.frame.size.height)
        }
        
        userImage.snp.makeConstraints { make in
            make.top.equalTo(mbtiLabel.snp.bottom).offset(padding * half)
            make.leading.equalTo(contentView.snp.leading).offset(padding)
            make.trailing.equalTo(contentView.snp.trailing).offset(padding)
            make.width.equalTo(contentView.snp.width).offset(-padding * 2)
            make.height.equalTo(contentView.snp.width).offset(-padding * 2)
        }
        
        userNickname.snp.makeConstraints { make in
            make.top.equalTo(userImage.snp.bottom).offset(padding * half)
            make.centerX.equalTo(contentView.snp.centerX)
        }
        
        userAge.snp.makeConstraints { make in
            make.top.equalTo(userNickname.snp.bottom)
            make.centerX.equalTo(contentView.snp.centerX)
        }
        
        userInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(userAge.snp.bottom).offset(padding)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
}
