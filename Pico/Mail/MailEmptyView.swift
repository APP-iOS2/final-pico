//
//  MailEmptyView.swift
//  Pico
//
//  Created by 양성혜 on 2023/09/26.
//

import UIKit
import SnapKit

final class MailEmptyView: UIView {
    
    private let mainImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "chu")
        return imageView
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "마음에 드시는 분과 대화를 나눠보세요\n서로 좋아요가 연결되는 순간 채팅이 만들어집니다"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = UIFont.picoDescriptionFont
        label.textColor = .picoFontBlack
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        addViews()
        makeConstraints()
    }
    
    private func addViews() {
        [mainImage, descriptionLabel].forEach { item in
            addSubview(item)
        }
    }
    
    private func makeConstraints() {
        mainImage.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.size.equalTo(Screen.width * 0.5)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(mainImage.snp.bottom)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
