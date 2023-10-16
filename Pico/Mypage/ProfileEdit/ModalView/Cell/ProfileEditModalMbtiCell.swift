//
//  ProfileEditModalMbtiCell.swift
//  Pico
//
//  Created by 김민기 on 2023/10/16.
//

import UIKit
import SnapKit

final class ProfileEditModalMbtiCell: UICollectionViewCell {
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .picoContentFont
        label.textColor = .picoFontGray
        label.text = "하이하이"
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubView()
        makeConstraints()
        cellConfigure()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                contentView.backgroundColor = .picoBetaBlue
                contentLabel.textColor = .black
            } else {
                contentView.backgroundColor = .clear
                contentLabel.textColor = .picoFontGray
            }
        }
    }
    
    private func cellConfigure() {
        contentView.layer.masksToBounds = false
        contentView.layer.borderColor = UIColor.picoFontGray.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 15
    }
    
    func configure(content: String) {
        contentLabel.text = content
    }
    
    private func addSubView() {
        contentView.addSubview([contentLabel])
    }
    
    private func makeConstraints() {
        contentLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
