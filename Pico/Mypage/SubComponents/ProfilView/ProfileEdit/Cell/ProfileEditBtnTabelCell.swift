//
//  ProfileEditBtnTabelCell.swift
//  Pico
//
//  Created by 김민기 on 2023/09/27.
//

import UIKit

final class ProfileEditBtnTabelCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubView()
        makeConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubView() {
        [].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func makeConstraints() {
    }
}
