//
//  ProfileEditEmptyCollectionCell.swift
//  Pico
//
//  Created by 김민기 on 2023/10/13.
//

import UIKit
import SnapKit
import Kingfisher

final class ProfileEditEmptyCollectionCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(systemName: "plus")
        imageView.image = image
        imageView.tintColor = .lightGray
        imageView.contentMode = .scaleAspectFit
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
        imageView.image = UIImage(systemName: "plus")
    }
    
    func cellConfigure() {
        contentView.backgroundColor = .picoLightGray
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 10
    }
    
    private func addSubView() {
        [imageView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
    }
}
