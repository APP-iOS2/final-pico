//
//  LoadingAnimationView.swift
//  Pico
//
//  Created by 방유빈 on 2023/10/04.
//

import UIKit

final class LoadingAnimationView: UIView {
    private let circleSize = 15
    
    private let dotStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = 10
        return stackView
    }()
    
    private let circleA = UIView()
    private let circleB = UIView()
    private let circleC = UIView()
    private lazy var circles = [circleA, circleB, circleC]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black.withAlphaComponent(0.3)
        addViews()
        makeConstraints()
        configCircle()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animate() {
        let jumpDuration: Double = 0.30
        let delayDuration: Double = 1.25
        let totalDuration: Double = delayDuration + jumpDuration * 2
        
        let jumpRelativeDuration: Double = jumpDuration / totalDuration
        let jumpRelativeTime: Double = delayDuration / totalDuration
        let fallRelativeTime: Double = (delayDuration + jumpDuration) / totalDuration
        layoutIfNeeded()
        
        for (index, circle) in circles.enumerated() {
            let delay = jumpDuration * 2 * TimeInterval(index) / TimeInterval(circles.count)
            UIView.animateKeyframes(withDuration: totalDuration, delay: delay, options: [.repeat], animations: {
                UIView.addKeyframe(withRelativeStartTime: jumpRelativeTime, relativeDuration: jumpRelativeDuration) {
                    circle.frame.origin.y -= 30
                }
                UIView.addKeyframe(withRelativeStartTime: fallRelativeTime, relativeDuration: jumpRelativeDuration) {
                    circle.frame.origin.y += 30
                }
            })
        }
    }
    
    private func configCircle() {
        circles.forEach {
            $0.layer.cornerRadius = CGFloat(circleSize / 2)
            $0.layer.masksToBounds = true
            $0.backgroundColor = .picoBlue
        }
    }
    
    private func addViews() {
        [dotStackView].forEach {
            addSubview($0)
        }
        circles.forEach {
            dotStackView.addArrangedSubview($0)
        }
    }
    
    private func makeConstraints() {
        dotStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        circles.forEach {
            $0.snp.makeConstraints { make in
                make.width.equalTo(circleSize)
                make.height.equalTo(circleSize)
            }
        }
    }
}
