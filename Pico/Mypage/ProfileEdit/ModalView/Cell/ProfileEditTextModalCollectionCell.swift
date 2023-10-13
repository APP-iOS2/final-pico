//
//  ProfileEditTextModalCollectionCell.swift
//  Pico
//
//  Created by 김민기 on 2023/10/13.
//

import UIKit
import SnapKit

final class ProfileEditTextModalCollectionCell: UICollectionViewCell {
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .picoContentFont
        label.textColor = .picoFontGray
        label.text = "하이하이"
        label.textAlignment = .center
        return label
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(configuration: .plain())
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .light)
        let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .black.withAlphaComponent(0.8)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubView()
        makeConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
//    override var isSelected: Bool {
//            didSet {
//                if isSelected {
//                    contentView.backgroundColor = .picoBetaBlue
//                    contentLabel.textColor = .black
//                } else {
//                    contentView.backgroundColor = .clear
//                    contentLabel.textColor = .picoFontGray
//                }
//            }
//        }
    
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
           let cell = ProfileEditTextModalCollectionCell()
           cell.configure(content: text)
           let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width, height: height)
        let fittingSize = cell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required)
        return CGSize(width: fittingSize.width + 30, height: height)
       }
    
    private func addSubView() {
        contentView.addSubview([contentLabel, deleteButton])
    }
    
    private func makeConstraints() {
        contentLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(7)
        }
        deleteButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing
                .equalToSuperview().offset(6)
        }
    }
}
