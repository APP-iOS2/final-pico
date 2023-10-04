//
//  SettingPrivateTableCell.swift
//  Pico
//
//  Created by 김민기 on 2023/09/26.
//

import UIKit

final class SettingPrivateTableCell: UITableViewCell {
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .picoAlphaWhite
        label.font = UIFont.picoSubTitleFont
        label.text = "아는 사람 만나지 않기"
        return label
    }()
   
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubView()
        makeConstraints()
        configView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func configView() {
        contentView.backgroundColor = .picoBlue
    }
    
    func configure(contentLabel: String) {
        self.contentLabel.text = contentLabel
    }
    
    private func addSubView() {
        [contentLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        contentLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
