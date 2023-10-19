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
        label.textAlignment = .center
        return label
    }()
    
     let deleteButton: UIButton = {
        let button = UIButton(configuration: .plain())
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 13, weight: .light)
        let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .black.withAlphaComponent(0.8)
        return button
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
    
    func configure(content: String) {
        contentLabel.text = content
    }
    
    private func addSubView() {
        contentView.addSubview([contentLabel, deleteButton])
    }
    
    private func cellConfigure() {
        contentView.layer.masksToBounds = false
        contentView.layer.borderColor = UIColor.picoFontGray.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 15
    }
    
    private func makeConstraints() {
        contentLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing
                .equalToSuperview().offset(6)
        }
    }
}
