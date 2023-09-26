//
//  MBTILabelView.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/26.
//

import UIKit
import SnapKit

/*
 사용법
 private let labelView: MBTILabelView = MBTILabelView(mbti: .entp)
 
 view.addSubview(labelView)
 
 labelView.snp.makeConstraints { make in
     make.centerX.centerY.equalToSuperview()
     make.height.equalTo(labelView.frame.size.height)
     make.width.equalTo(labelView.frame.size.width)
 }
 */

final class MBTILabelView: UIView {
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .picoMBTILabelFont
        label.textColor = .white
        return label
    }()
    
    convenience init(frame: CGRect = CGRect(x: 0, y: 0, width: 80, height: 40), mbti: MBTIType) {
        self.init(frame: frame)
        self.backgroundColor = UIColor(hex: mbti.colorName)
        self.layer.cornerRadius = 10
        textLabel.text = mbti.nameString
        
        addViews()
        makeConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews() {
        self.addSubview(textLabel)
    }
    
    private func makeConstraints() {
        textLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
}
