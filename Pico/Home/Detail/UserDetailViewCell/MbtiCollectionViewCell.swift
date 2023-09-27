//
//  MbtiCollectionViewCell.swift
//  Pico
//
//  Created by 신희권 on 2023/09/26.
//

import UIKit

class MbtiCollectionViewCell: UICollectionViewCell {
    private var mbtiView: UIView = MBTILabelView(mbti: .enfj)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        makeConstraints()
    }
    
    func config(mbtiType: MBTIType) {
        mbtiView = MBTILabelView(mbti: mbtiType)
    }
    
    private func addViews() {
        self.addSubview(mbtiView)
    }
    
    private func makeConstraints() {
        mbtiView.snp.makeConstraints { make in
            make.edges.equalToSuperview().offset(5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}