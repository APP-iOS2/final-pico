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
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .picoMBTILabelFont
        label.textColor = .white
        return label
    }()
    
    private var mbti: MBTIType
    
    convenience init(frame: CGRect = CGRect(x: 0, y: 0, width: 80, height: 40), mbti: MBTIType) {
        self.init(frame: frame)
        self.backgroundColor = UIColor(hex: mbti.colorName)
        self.layer.cornerRadius = 10
        textLabel.text = mbti.nameString
    }
    
    // !!! 질문: init에 디폴트 값을 주면 왜 안되는가.. (convenience 없을때)
    // override init(frame: CGRect = CGRect(x: 0, y: 0, width: 80, height: 40)) {
    override init(frame: CGRect) {
        self.mbti = .infj
        let adjustedFrame: CGRect = CGRect(x: 0, y: 0, width: 80, height: 40)
        super.init(frame: adjustedFrame)
        configUI()
        addViews()
        makeConstraints()
    }
    
    /* !!! 질문: makeConstraints를 layoutSubviews여기서 해주는가
    override func layoutSubviews() {
        makeConstraints()
    }
     */
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        self.backgroundColor = UIColor(hex: mbti.colorName)
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        textLabel.text = mbti.nameString
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
