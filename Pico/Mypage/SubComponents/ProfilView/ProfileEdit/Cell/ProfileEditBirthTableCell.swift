//
//  ProfileEditBirthTableCell.swift
//  Pico
//
//  Created by 김민기 on 2023/09/26.
//

import UIKit

final class ProfileEditBirthTableCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .picoFontBlack
        label.font = UIFont.picoSubTitleFont
        label.text = "생일"
        return label
    }()
    
    private lazy var birthChangeButton: UIButton = {
        let button = UIButton()
        button.setTitle("2000 - 01 - 22", for: .normal)
        button.setTitleColor(.picoFontBlack, for: .normal)
        button.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubView()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func tappedButton() {
        print("tap")
    }
    
    private func addSubView() {
        [titleLabel, birthChangeButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        
        birthChangeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
    }
}
