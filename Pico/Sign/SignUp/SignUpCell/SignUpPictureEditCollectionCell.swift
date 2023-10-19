//
//  SignUpPictureEditCollectionCell.swift
//  Pico
//
//  Created by LJh on 10/15/23.
//

import UIKit

final class SignUpPictureEditCollectionCell: UICollectionViewCell {
  
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .add
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let plusImageView: UIImageView = {
        let imageView = UIImageView()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .light)
        let image = UIImage(systemName: "plus.circle", withConfiguration: imageConfig)
        imageView.image = image
        imageView.tintColor = .white.withAlphaComponent(0.8)
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
    
    func configure(imageName: String, isHidden: Bool) {
        plusImageView.isHidden = isHidden
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
        [imageView, plusImageView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        plusImageView.snp.makeConstraints { make in
            make.centerX.equalTo(imageView.snp.centerX)
            make.centerY.equalTo(imageView.snp.centerY)
        }
    }
}
