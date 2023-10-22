//
//  StoreTableBannerCell.swift
//  Pico
//
//  Created by 김민기 on 2023/09/26.
//

import UIKit
import SnapKit
import Lottie

final class StoreTableBannerCell: UITableViewCell {

    private let boxTitleImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "randomBoxImage")
        return imageView
    }()
    
    private let boxContentLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.picoDescriptionFont
        label.text = "꽝은 절대 없다!\n랜덤박스를 열어 부족한 츄를 획득해보세요!"
        label.numberOfLines = 0
        return label
    }()
        
    let animationView = LottieAnimationView(name: "randomBox")
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubView()
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
        
    private func addSubView() {
        addSubview([boxTitleImage, boxContentLabel])
    }
    
    private func makeConstraints() {

        boxTitleImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.leading.trailing.equalToSuperview().inset(50)
            make.height.equalTo(50)
        }
        boxContentLabel.snp.makeConstraints { make in
            make.top.equalTo(boxTitleImage.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
}
