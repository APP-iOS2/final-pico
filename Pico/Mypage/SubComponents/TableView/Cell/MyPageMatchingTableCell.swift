//
//  MyPageMatchingTableCell.swift
//  Pico
//
//  Created by 김민기 on 2023/09/26.
//

import UIKit

final class MyPageMatchingTableCell: UITableViewCell {

    private let tableImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        return imageView
    }()
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
    private let premiumLabel: UILabel = {
        let label = UILabel()
        label.textColor = .picoFontBlack
        label.font = UIFont.picoSubTitleFont
        label.text = "premium"
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = .purple
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 20
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
        [tableImageView, titleLabel, subtitleLabel, premiumLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        tableImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(15)
            make.height.equalTo(25)
            make.width.equalTo(90)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().inset(10)
            make.bottom.equalTo(subtitleLabel.snp.top).offset(-2)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-15)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().inset(10)
        }
        premiumLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-10)
            make.width.equalTo(110)
            make.height.equalTo(40)
        }
    }
}
