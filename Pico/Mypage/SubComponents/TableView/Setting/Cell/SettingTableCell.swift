//
//  StoreTableCell.swift
//  Pico
//
//  Created by 김민기 on 2023/09/26.
//

import UIKit

final class SettingTableCell: UITableViewCell {
    
    static let identifier = "SettingTableCell"
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .picoFontBlack
        label.font = UIFont.picoSubTitleFont
        label.text = "약관 내용"
        return label
    }()
   
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubView()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
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
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
    }
}
