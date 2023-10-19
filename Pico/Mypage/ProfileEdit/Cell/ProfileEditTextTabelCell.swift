//
//  ProfileEditTextTabelCell.swift
//  Pico
//
//  Created by 김민기 on 2023/09/27.
//

import UIKit

final class ProfileEditTextTabelCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .picoFontBlack
        label.font = UIFont.picoSubTitleFont
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .picoFontBlack
        label.font = UIFont.picoDescriptionFont
        label.text = "추가"
        return label
    }()
    
    private let nextImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .lightGray
        imageView.contentMode = .scaleAspectFit
        return imageView
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentLabel.text = "추가"
        contentLabel.textAlignment = .right
        titleLabel.text = nil
        nextImageView.image = UIImage(systemName: "chevron.right")
    }
    
    func configure(titleLabel: String, contentLabel: String?) {
        self.titleLabel.text = titleLabel
        guard let contentLabel else { return }
        if !contentLabel.isEmpty {
            self.contentLabel.text = contentLabel
        }
    }
    
    private func addSubView() {
        [titleLabel, contentLabel, nextImageView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalTo(contentLabel.snp.leading).offset(-50)
            make.centerY.equalToSuperview()
        }
        
        contentLabel.snp.makeConstraints { make in
            make.trailing.equalTo(nextImageView.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
        }
        
        nextImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }
}
