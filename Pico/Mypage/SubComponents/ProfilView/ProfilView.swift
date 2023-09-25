//
//  ProfilViewController.swift
//  Pico
//
//  Created by 김민기 on 2023/09/25.
//

import UIKit

final class ProfilView: UIView {
    
    private let percentView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 70
        view.backgroundColor = .gray
        return view
    }()
    
    private let userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 70
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(named: "chu")
        return imageView
    }()
    
    private let editImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pencil")
        imageView.backgroundColor = .white
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 27
        return imageView
    }()
    
    private let profilPercentLabel: UILabel = {
        let label = UILabel()
        label.text = "25% 완성"
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 20
        label.textColor = .white
        label.backgroundColor = .red
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        makeConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews() {
        [percentView, userImage, editImageView, profilPercentLabel].forEach {
            addSubview($0)
        }
    }
    
    private func makeConstraints() {
        userImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.width.equalTo(140)
        }
        percentView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.width.equalTo(160)
        }
        editImageView.snp.makeConstraints { make in
            make.top.equalTo(percentView.snp.top).offset(-10)
            make.trailing.equalTo(percentView.snp.trailing).offset(10)
            make.height.width.equalTo(54)
        }
        profilPercentLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(percentView.snp.bottom).offset(-30)
            make.height.equalTo(40)
            make.width.equalTo(100)
        }
    }
}
