//
//  HomeEmptyViewController.swift
//  Pico
//
//  Created by 임대진 on 9/29/23.
//

import UIKit
import SnapKit

final class HomeEmptyView: UIView {
    
    private let tempImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "tempImage"))
        return imageView
    }()
    
    private let finishLabel: UILabel = {
        let label = UILabel()
        label.text = "이번 추천이 완료되었습니다."
        label.textAlignment = .center
        return label
    }()
    
    lazy var reLoadButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.setTitle("새 친구 추천 받기", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        return button
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
    
    private func addViews() {
        [reLoadButton, tempImage, finishLabel].forEach { item in
            addSubview(item)
        }
    }
    
    private func makeConstraints() {
        tempImage.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.size.equalTo(Screen.width * 0.5)
        }
        finishLabel.snp.makeConstraints { make in
            make.top.equalTo(tempImage.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        reLoadButton.snp.makeConstraints { make in
            make.top.equalTo(finishLabel).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
    }
}
