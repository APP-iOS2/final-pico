//
//  SignLoadingAnimationView.swift
//  Pico
//
//  Created by LJh on 10/15/23.
//
import UIKit
import SnapKit

final class SignLoadingAnimationView: UIView {
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
        
        var alphaValue: CGFloat {
            switch self {
            case .large:
                return 0.3
            case .small:
                return 0.2
            }
        }
    }
    
    private let waitLabel: UILabel = {
        let label = UILabel()
        label.text = "잠시만용~ 평가중이에요."
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.picoSubTitleFont
        label.textColor = .picoAlphaBlue
        return label
    }()
    
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
    private var waitText: String
    
    init(circleSize: CircleSize = .large, waitText: String) {
        self.circleSize = circleSize
        self.waitText = waitText
        super.init(frame: .zero)
        
        backgroundColor = .black.withAlphaComponent(circleSize.alphaValue)
        addViews()
        makeConstraints()
        configCircle()
        configLabel()
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
            UIView.animateKeyframes(withDuration: totalDuration, delay: delay, options: [.repeat], animations: { [weak self] in 
                guard let self = self else { return }
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
            $0.layer.cornerRadius = CGFloat(circleSize.value / 2)
            $0.layer.masksToBounds = true
            $0.backgroundColor = .picoBlue
        }
    }
    private func configLabel() {
        waitLabel.text = waitText
    }
    
    private func addViews() {
        [dotStackView, waitLabel].forEach {
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
        waitLabel.snp.makeConstraints { make in
                make.top.equalTo(dotStackView.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
        }
    }
}
