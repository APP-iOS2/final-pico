//
//  WorldCupTableViewCell.swift
//  Pico
//
//  Created by 오영석 on 2023/09/26.
//

import UIKit
import SnapKit

final class WorldCupCollectionViewCell: UICollectionViewCell {

    private let mbtiLabel: UILabel = {
        let label = UILabel()
        label.text = "ENFP"
        label.textAlignment = .center
        label.font = UIFont.picoTitleFont

        return label
    }()

    private let userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "woman1")

        return imageView
    }()

    private let userNickname: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.text = "냥냥펀치"

        return label
    }()

    private let userAge: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.text = "22"

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        addViews()
        makeConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addViews() {
        [mbtiLabel, userImage, userNickname, userAge].forEach { item in
            contentView.addSubview(item)
        }
    }

    private func makeConstraints() {
        let padding: CGFloat = 10

        mbtiLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(padding)
            make.leading.equalTo(contentView.snp.leading).offset(padding)
            make.trailing.equalTo(contentView.snp.trailing).offset(-padding)
        }

        userImage.snp.makeConstraints { make in
            make.top.equalTo(mbtiLabel.snp.bottom).offset(padding * 0.5)
            make.leading.equalTo(contentView.snp.leading).offset(padding)
            make.trailing.equalTo(contentView.snp.trailing).offset(padding)
            make.width.equalTo(contentView.snp.width).offset(-padding * 2)
            make.height.equalTo(contentView.snp.width).offset(-padding * 2)
        }

        userNickname.snp.makeConstraints { make in
            make.top.equalTo(userImage.snp.bottom).offset(padding * 0.5)
            make.leading.equalTo(contentView.snp.leading).offset(padding)
            make.trailing.equalTo(userAge.snp.leading).offset(-padding * 0.5)
        }

        userAge.snp.makeConstraints { make in
            make.top.equalTo(userImage.snp.bottom).offset(padding * 0.5)
            make.leading.equalTo(userNickname.snp.trailing).offset(padding * 0.5)
            make.trailing.equalTo(contentView.snp.trailing).offset(-padding)
        }
    }
}
