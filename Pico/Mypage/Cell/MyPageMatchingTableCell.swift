//
//  MyPageMatchingTableCell.swift
//  Pico
//
//  Created by 김민기 on 2023/09/26.
//

import UIKit
import SnapKit

final class MyPageMatchingTableCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .picoFontBlack
        label.font = UIFont.picoSubTitleFont
        label.text = "파워 매칭 서비스 제공"
        return label
    }()
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .picoFontGray
        label.font = UIFont.picoDescriptionFont
        label.text = "나와 성향이 잘 맞는 사람 우선 추천"
        return label
    }()
    private let premiumImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "premiumImage")
        return imageView
    }()
    private let premiumLabel: UILabel = {
        let label = UILabel()
        label.textColor = .picoFontBlack
        label.font = UIFont.picoSubTitleFont
        label.text = "premiumImage"
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = .purple
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 17
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubView()
        makeConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func addSubView() {
        [premiumImage, titleLabel, subtitleLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        premiumImage.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(120)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(premiumImage)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().inset(10)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().inset(10)
        }
    }
}
