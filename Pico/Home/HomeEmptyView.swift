//
//  HomeEmptyViewController.swift
//  Pico
//
//  Created by 임대진 on 9/29/23.
//

import UIKit
import SnapKit
import Lottie

final class HomeEmptyView: UIView {
    
    private let animationView: LottieAnimationView = {
        let view = LottieAnimationView(name: "HomeEmptyLottie")
        view.contentMode = .scaleAspectFit
        view.center = view.center
        view.loopMode = .loop
        view.animationSpeed = 0.75
        view.backgroundBehavior = .pauseAndRestore
        return view
    }()
    
    private let chuImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "chu"))
        return imageView
    }()
    
    private let finishLabel: UILabel = {
        let label = UILabel()
        let text = """
                    더 이상 추천이 없어요.
                    선호 설정을 조절해 보세요.
                    """
        let attributedText = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        attributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.length))
        label.attributedText = attributedText
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .picoContentFont
        return label
    }()
    
    // 상위뷰에서 에드타겟
    let reLoadButton: UIButton = {
        let button = UIButton()
        button.setTitle("새 친구 찾아보기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .picoButtonFont
        button.backgroundColor = .picoBlue
        button.layer.cornerRadius = 15
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        makeConstraints()
        animationView.play()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews() {
        [animationView, chuImage, reLoadButton, finishLabel].forEach { item in
            addSubview(item)
        }
    }

    private func makeConstraints() {
        animationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
            make.width.height.equalTo(600)
        }
        
        chuImage.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(animationView)
            make.width.height.equalTo(60)
        }
        
        finishLabel.snp.makeConstraints { make in
            make.top.equalTo(animationView.snp.bottom).offset(-120)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        reLoadButton.snp.makeConstraints { make in
            make.top.equalTo(finishLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(140)
            make.height.equalTo(35)
        }
    }
}
