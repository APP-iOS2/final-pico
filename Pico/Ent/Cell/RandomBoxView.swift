//
//  RandomBoxCell.swift
//  Pico
//
//  Created by 오영석 on 2023/09/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class RandomBoxView: UICollectionReusableView {
    
    private let boxChuImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "chu")
        return imageView
    }()
    
    private let boxTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.picoTitleFont
        label.text = "Random Box"
        return label
    }()
    
    private let boxContentLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.picoDescriptionFont
        label.text = "꽝은 절대 없다!\n랜덤박스를 열어 츄를 획득해보세요\n( 1일 1회 무료 )"
        label.numberOfLines = 0
        return label
    }()
    
    private let boxChuChuImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "chu")
        return imageView
    }()
    
    private let boxChuLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.picoDescriptionFont
        label.text = "10"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configStyle()
        addViews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configStyle() {
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 10
    }
    
    private func addViews() {
        [boxChuImage, boxTitleLabel, boxContentLabel, boxChuChuImage, boxChuLabel].forEach { item in
            addSubview(item)
        }
    }
    
    private func makeConstraints() {
        let padding: CGFloat = 10
        let half: CGFloat = 0.5
        
        boxChuImage.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(-padding)
            make.width.height.equalTo(100)
        }
        
        boxTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(boxChuImage).offset(padding)
            make.leading.equalTo(boxChuImage.snp.trailing).offset(-padding)
            make.trailing.equalToSuperview().offset(-padding)
        }
        
        boxContentLabel.snp.makeConstraints { make in
            make.top.equalTo(boxTitleLabel.snp.bottom).offset(padding * half)
            make.leading.equalTo(boxTitleLabel)
            make.trailing.equalToSuperview().offset(-padding)
        }
        
        boxChuChuImage.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-padding * 3)
            make.centerY.equalTo(boxTitleLabel)
            make.width.height.equalTo(padding * 3)
        }

        boxChuLabel.snp.makeConstraints { make in
            make.leading.equalTo(boxChuChuImage.snp.trailing).offset(-padding * half)
            make.trailing.equalToSuperview().offset(-padding)
            make.centerY.equalTo(boxChuChuImage)
        }

    }
}
