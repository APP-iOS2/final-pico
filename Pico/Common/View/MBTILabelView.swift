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
     // top, leading 제약조건 추가
     make.height.equalTo(labelView.frame.size.height)
     make.width.equalTo(labelView.frame.size.width)
 }
 */

final class MBTILabelView: UIView {
    enum LabelScale {
        case large
        case small
        
        var frameSize: CGRect {
            switch self {
            case .large:
                return CGRect(x: 0, y: 0, width: 80, height: 40)
            case .small:
                return CGRect(x: 0, y: 0, width: 50, height: 20)
            }
        }
        
        var font: UIFont {
            switch self {
            case .large:
                return .picoMBTILabelFont
            case .small:
                return .picoMBTISmallLabelFont
            }
        }
        
        var radius: CGFloat {
            switch self {
            case .large:
                return 8
            case .small:
                return 5
            }
        }
    }
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        return label
    }()
    
    private var mbti: MBTIType
    private var labelScale: LabelScale
    
    init(mbti: MBTIType, scale: LabelScale) {
        self.mbti = mbti
        self.labelScale = scale
        
        super.init(frame: labelScale.frameSize)
        
        configUI()
        addViews()
        makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setMbti(mbti: MBTIType) {
        textLabel.text = mbti.nameString
        self.backgroundColor = UIColor(hex: mbti.colorName)
    }
    
    private func configUI() {
        self.backgroundColor = UIColor(hex: mbti.colorName)
        self.layer.cornerRadius = labelScale.radius
        self.clipsToBounds = true
        textLabel.text = mbti.nameString
        textLabel.font = self.labelScale.font
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
