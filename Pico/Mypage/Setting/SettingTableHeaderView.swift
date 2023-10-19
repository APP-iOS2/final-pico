//
//  SettingTableHeaderView.swift
//  Pico
//
//  Created by 김민기 on 2023/09/26.
//

import UIKit

class SettingTableHeaderView: UITableViewHeaderFooterView {
    
    static let identifier = "SettingTableHeaderView"
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.font = .picoDescriptionFont
        label.textColor = .picoFontGray
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubView()
        makeConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(headerLabel: String) {
        self.headerLabel.text = headerLabel
    }
    
    private func addSubView() {
        [headerLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        headerLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
    }
}
