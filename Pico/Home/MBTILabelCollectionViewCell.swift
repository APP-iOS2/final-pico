//
//  MBTILabelCollectionViewCell.swift
//  Pico
//
//  Created by 임대진 on 2023/09/27.
//

import UIKit

final class MBTILabelCollectionViewCell: UICollectionViewCell {
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .picoMBTILabelFont
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = .picoGray
        layer.cornerRadius = 10
        clipsToBounds = true
        
        addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    func configureWithMBTI(_ mbti: MBTIType) {
        textLabel.text = mbti.rawValue.uppercased()
        backgroundColor = UIColor(hex: mbti.colorName)
    }
}
