//
//  LoadingAnimationView.swift
//  Pico
//
//  Created by 방유빈 on 2023/10/04.
//

import UIKit

final class LoadingAnimationView: UIView {
    enum CircleSize {
        case large
        case small
        
        var value: Int {
            switch self {
            case .large:
                return 15
            case .small:
                return 9
            }
        }
    }
    
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
    
    private var circleSize: CircleSize
    
    init(circleSize: CircleSize = .large) {
        self.circleSize = circleSize
        super.init(frame: .zero)
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
    
    func animateNow() {
        let jumpDuration: Double = 0.30
        let delayDuration: Double = 1.25
        let totalDuration: Double = delayDuration + jumpDuration * 2
        
        let jumpRelativeDuration: Double = jumpDuration / totalDuration
        layoutIfNeeded()
        
        for (index, circle) in circles.enumerated() {
            let delay = jumpDuration * 2 * TimeInterval(index) / TimeInterval(circles.count)
            UIView.animateKeyframes(withDuration: totalDuration, delay: delay, options: [.repeat], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: jumpRelativeDuration) {
                    circle.frame.origin.y -= 30
                }
                UIView.addKeyframe(withRelativeStartTime: 1, relativeDuration: jumpRelativeDuration) {
                    circle.frame.origin.y += 30
                }
            })
        }
    }
    
    private func configCircle() {
        circles.forEach {
            $0.layer.cornerRadius = CGFloat(circleSize.value / 2)
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
                make.width.equalTo(circleSize.value)
                make.height.equalTo(circleSize.value)
            }
        }
    }
}
