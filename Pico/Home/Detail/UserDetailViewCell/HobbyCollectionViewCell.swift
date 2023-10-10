//
//  HobbyCollectionViewCell.swift
//  Pico
//
//  Created by 신희권 on 2023/09/26.
//

import UIKit

final class HobbyCollectionViewCell: UICollectionViewCell {
    private let label: UILabel = {
        let label = UILabel()
        label.text = "test"
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 6
        label.font = UIFont.picoDescriptionFont
        label.textAlignment = .center
        label.backgroundColor = .picoGray
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        makeConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(labelText: String) {
        label.text = labelText
    }
    
    private func addViews() {
        self.addSubview(label)
    }
    
    private func makeConstraints() {
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
