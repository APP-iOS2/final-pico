//
//  ProfileEditCollectionCell.swift
//  Pico
//
//  Created by 김민기 on 2023/09/27.
//

import UIKit
import SnapKit

final class ProfileEditCollectionCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .add
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubView()
        makeConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        imageView.image = .add
    }
    
    func configure(imageName: String) {
    }
    
    func configure(image: UIImage) {
        imageView.image = image
    }
    
    private func addSubView() {
        [imageView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
