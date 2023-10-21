//
//  MyPageCollectionCell.swift
//  Pico
//
//  Created by 김민기 on 2023/09/26.
//

import UIKit
import SnapKit

final class MyPageCollectionCell: UICollectionViewCell {
    
    private let image: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        return image
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .picoFontBlack
        label.font = .picoSubTitleSmallFont
        return label
    }()
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .picoGradientMedium
        label.font = .picoSubTitleSmallFont
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubView()
        makeConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(imageName: String, title: String, subTitle: String) {
        image.image = UIImage(named: imageName)
        titleLabel.text = title
        subTitleLabel.text = subTitle
    }
    
    private func addSubView() {
        [image, titleLabel, subTitleLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        image.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(3)
            make.centerX.equalToSuperview()
            make.height.equalTo(45)
            make.width.equalTo(40)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(image.snp.bottom).offset(-6)
            make.centerX.equalToSuperview()
        }
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.centerX.equalToSuperview()
        }
    }
}
