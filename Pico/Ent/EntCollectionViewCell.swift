//
//  EntCollectionViewCell.swift
//  Pico
//
//  Created by 오영석 on 2023/09/25.
//

import UIKit

final class EntCollectionViewCell: UICollectionViewCell {
    
    private let cellImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "chu")
        
        return imageView
    }()
    
    private let firstLabel: UILabel = {
        let label = UILabel()
        label.text = "이상형 월드컵"
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    private let secondLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘 내가 선택한 이성은 누구?\n최종 선택 시 상품 증정!"
        label.textAlignment = .left
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        makeConstraints()
        border()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func border() {
        cellImage.layer.borderWidth = 1.0
        cellImage.layer.cornerRadius = 10.0
        cellImage.layer.borderColor = UIColor.black.cgColor
    }
    
    private func addViews() {
        contentView.addSubview(cellImage)
        contentView.addSubview(firstLabel)
        contentView.addSubview(secondLabel)
    }
    
    private func makeConstraints() {
        let padding: CGFloat = 10
        
        cellImage.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(contentView)
            make.height.equalTo(contentView.bounds.width)
        }
        
        firstLabel.snp.makeConstraints { make in
            make.top.equalTo(cellImage.snp.bottom).offset(-padding)
            make.leading.trailing.equalTo(contentView)
        }
        
        secondLabel.snp.makeConstraints { make in
            make.top.equalTo(firstLabel.snp.bottom).offset(-padding)
            make.leading.trailing.equalTo(contentView)
            make.bottom.equalTo(contentView).offset(-padding * 0.5)
        }
    }
    
}
