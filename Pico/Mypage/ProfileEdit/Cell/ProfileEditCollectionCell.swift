//
//  ProfileEditCollectionCell.swift
//  Pico
//
//  Created by 김민기 on 2023/09/27.
//

import UIKit
import SnapKit
import Kingfisher

final class ProfileEditCollectionCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .add
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton(configuration: .plain())
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .light)
        let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .white.withAlphaComponent(0.8)
        return button
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
    
    func configure(imageName: String) {
        guard let url = URL(string: imageName) else { return }
        imageView.kf.setImage(with: url)
        imageView.contentMode = .scaleAspectFill
    }
    
    func configure(image: UIImage) {
        imageView.image = image
    }
    
    func cellConfigure() {
        contentView.backgroundColor = .picoLightGray
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 10
    }
    
    private func addSubView() {
        [imageView, deleteButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().offset(7)
        }
    }
}
