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

final class RandomBoxView: UIView {
    
    private let leftChuImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "chu")
        return imageView
    }()
    
    private let boxTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.picoLargeTitleFont
        label.text = "Random Box"
        label.textColor = .picoBlue
        return label
    }()
    
    private let boxContentLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.picoDescriptionFont
        label.text = "꽝은 절대 없다!\n하루 한 번 무료!"
        label.numberOfLines = 0
        return label
    }()
    
    private let rightChuImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "chu")
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configStyle()
        addViews()
        makeConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configStyle() {
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 10
        self.layer.borderColor = UIColor.picoBlue.cgColor
    }
    
    private func addViews() {
        [leftChuImage, boxTitleLabel, boxContentLabel, rightChuImage].forEach { item in
            addSubview(item)
        }
    }
    
    private func makeConstraints() {
        let padding: CGFloat = 10
        let half: CGFloat = 0.5
        
        leftChuImage.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview().offset(half)
            make.width.equalTo(leftChuImage.snp.height).offset(-padding)
            make.height.equalToSuperview().offset(-padding * 2)
        }
        
        boxTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(leftChuImage.snp.top).offset(padding * half)
            make.centerX.equalToSuperview()
        }
        
        boxContentLabel.snp.makeConstraints { make in
            make.top.equalTo(boxTitleLabel.snp.bottom).offset(padding * half)
            make.centerX.equalTo(boxTitleLabel)
            make.bottom.equalTo(leftChuImage.snp.bottom).offset(-padding * half)
        }
        
        rightChuImage.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview().offset(half)
            make.width.equalTo(leftChuImage)
            make.height.equalTo(leftChuImage)
        }
    }
}
