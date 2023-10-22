//
//  HomeEmptyViewController.swift
//  Pico
//
//  Created by 임대진 on 9/29/23.
//

import UIKit
import SnapKit

final class HomeEmptyView: UIView {
    
    private let chuImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "chu"))
        return imageView
    }()
    
    private let magnifierImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "magnifier"))
        return imageView
    }()
    
    private let finishLabel: UILabel = {
        let label = UILabel()
        label.text = "더 이상 추천이 없어요, 선호 설정을 조절해 보세요."
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()
    
    lazy var reLoadButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.setTitle("새 친구 찾아보기", for: .normal)
        button.setTitleColor(.gray, for: .normal)
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
        [reLoadButton, chuImage, finishLabel].forEach { item in
            addSubview(item)
        }
    }
    
    func animate() {
        let circleSize: CGFloat = 12.5
        magnifierImage.frame = CGRect(x: center.x - 25, y: center.y - 25, width: 40, height: 40)
        let path = UIBezierPath(ovalIn: CGRect(x: center.x - magnifierImage.frame.width / 4, y: chuImage.frame.minY, width: circleSize, height: circleSize))
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = path.cgPath
        animation.duration = 1.5 // 전체 움직임에 걸리는 시간
        animation.repeatCount = .greatestFiniteMagnitude
        animation.calculationMode = .paced
        
        magnifierImage.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        magnifierImage.layer.add(animation, forKey: "circleAnimation")
    }

    private func makeConstraints() {
        chuImage.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.size.equalTo(Screen.width * 0.5)
        }
        
        finishLabel.snp.makeConstraints { make in
            make.top.equalTo(chuImage.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        reLoadButton.snp.makeConstraints { make in
            make.top.equalTo(finishLabel).offset(40)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
    }
}
