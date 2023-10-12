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
    
    private let mbtiButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = .picoGray
        layer.cornerRadius = 10
        clipsToBounds = true
        
        addSubview(mbtiButton)
        mbtiButton.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
    }
    
    func configureWithMBTI(_ mbti: MBTIType) {
        mbtiButton.setTitle(mbti.rawValue.uppercased(), for: .normal)
        mbtiButton.titleLabel?.font = .picoMBTILabelFont
        mbtiButton.isUserInteractionEnabled = true
        mbtiButton.addTarget(self, action: #selector(buttonTouch), for: .touchUpInside)
    }
//    private func updateButtonAppearance(_ button: UIButton) {
//        guard let mbti = button.titleLabel?.text?.lowercased() as? MBTIType else { return }
//        button.setTitleColor(button.isSelected ? .white : .picoFontGray, for: .normal)
//    }
    @objc func buttonTouch() {
        mbtiButton.isSelected.toggle()
        if let buttonText = mbtiButton.titleLabel?.text?.lowercased() {
            if let mbti = MBTIType(rawValue: buttonText) {
                backgroundColor = mbtiButton.isSelected ? UIColor(hex: mbti.colorName) : .picoGray
            }
        }
    }

}
