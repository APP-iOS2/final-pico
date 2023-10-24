//
//  MyPageDefaultTableCell.swift
//  Pico
//
//  Created by 김민기 on 2023/09/26.
//

import UIKit
import SnapKit

final class MyPageDefaultTableCell: UITableViewCell {

    private let tableImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .darkGray
        return imageView
    }()
    
    private let tableLabel: UILabel = {
        let label = UILabel()
        label.textColor = .picoFontBlack
        label.font = UIFont.picoSubTitleFont
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
    
    func configure(imageName: String, title: String) {
        tableImageView.image = UIImage(systemName: imageName)
        tableLabel.text = title
    }
    
    private func addSubView() {
        [tableImageView, tableLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        tableImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.height.width.equalTo(25)
        }
        
        tableLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(tableImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
    }
}
