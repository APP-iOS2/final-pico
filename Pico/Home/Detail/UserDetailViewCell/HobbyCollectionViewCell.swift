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
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 4
        label.font = .picoButtonFont
        label.textAlignment = .center
        label.backgroundColor = .systemGray6
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        makeConstraints()
    }
    
    func config(labelText: String) {
        label.text = labelText
    }
    
    private func addViews() {
        contentView.addSubview(label)
    }
    
    private func makeConstraints() {
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
