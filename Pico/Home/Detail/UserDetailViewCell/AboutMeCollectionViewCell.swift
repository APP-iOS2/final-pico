//
//  AboutMeCollectionViewCell.swift
//  Pico
//
//  Created by 신희권 on 10/18/23.
//

import UIKit
import SnapKit

class AboutMeCollectionViewCell: UICollectionViewCell {
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 10
        return stackView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .darkGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .picoContentBoldFont
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        makeConstraints()
    }
    
    func config(image: String, title: String) {
        if image == "smoke" || image == "religion" {
            self.imageView.image = UIImage(named: image)
        } else {
            self.imageView.image = UIImage(systemName: image)
        }
        self.titleLabel.text = title
    }
    
    private func addViews() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview([imageView, titleLabel])
    }
    
    private func makeConstraints() {
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
//            make.leading.equalToSuperview()
            make.width.height.equalTo(20)
        }
//        
//        titleLabel.snp.makeConstraints { make in
//            make.top.equalTo(imageView)
//            make.leading.equalTo(imageView.snp.trailing).offset(10)
//        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
