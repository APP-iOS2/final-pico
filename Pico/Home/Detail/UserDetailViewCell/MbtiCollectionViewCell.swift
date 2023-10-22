//
//  MbtiCollectionViewCell.swift
//  Pico
//
//  Created by 신희권 on 2023/09/26.
//

import UIKit

final class MbtiCollectionViewCell: UICollectionViewCell {
    private var mbtiView: MBTILabelView = MBTILabelView(mbti: .infp, scale: .small)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        makeConstraints()
    }
    
    func config(mbtiType: MBTIType) {
      mbtiView.setMbti(mbti: mbtiType)
    }
    
    private func addViews() {
        contentView.addSubview(mbtiView)
    }
    
    private func makeConstraints() {
        mbtiView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
