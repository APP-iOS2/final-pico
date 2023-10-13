//
//  ProfileEditModalCollectionCell.swift
//  Pico
//
//  Created by 김민기 on 2023/10/13.
//

import UIKit
import SnapKit

final class ProfileEditModalCollectionCell: UICollectionViewCell {
    
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
    }
    
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
    
    func cellConfigure() {
        contentView.layer.masksToBounds = false
        contentView.layer.borderColor = UIColor.picoFontGray.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 15
    }
    
    func configure(content: String) {
        contentLabel.text = content
    }
    
    static func fittingSize(height: CGFloat, text: String) -> CGSize {
        let cell = ProfileEditModalCollectionCell()
        cell.configure(content: text)
        let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width, height: height)
        let fittingSize = cell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required)
        return CGSize(width: fittingSize.width + 30, height: height)
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
