//
//  AboutMeCollectionViewCell.swift
//  Pico
//
//  Created by 신희권 on 10/18/23.
//

import UIKit

class AboutMeCollectionViewCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        makeConstraints()
    }
    
    func config(image: String, title: String) {
        self.imageView.image = UIImage(systemName: image)
        self.titleLabel.text = title
    }
    
    private func addViews() {
        [imageView, titleLabel].forEach { contentView.addSubview($0) }
    }
    
    private func makeConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(imageView.snp.trailing).offset(10)
            make.trailing.bottom.equalToSuperview()
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
