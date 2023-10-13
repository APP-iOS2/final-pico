//
//  RangeSlider.swift
//  Pico
//
//  Created by 임대진 on 10/12/23.
//

import UIKit
import SnapKit

final class RangeSlider: UIView {
    private let sliderBar = UIView()
    private let rangeStick = UIView()
    private let leftBall = UIImageView()
    private let rightBall = UIImageView()
    private var initialCenter = CGPoint()
    private let ballSize = 25
    private var leftPoint = 20
    private var rightPoint = 200
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubView()
        makeConstraints()
        configUI()
        configGesture()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubView() {
        addSubview([sliderBar, rangeStick, leftBall, rightBall])
    }
    
    private func makeConstraints() {
        sliderBar.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(4)
        }
        
        rangeStick.snp.updateConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(sliderBar.snp.leading).offset(leftPoint)
            make.trailing.equalTo(sliderBar.snp.leading).offset(rightPoint)
            make.height.equalTo(4)
        }
        
        leftBall.snp.makeConstraints { make in
            make.centerX.equalTo(sliderBar.snp.leading).offset(leftPoint)
            make.centerY.equalTo(sliderBar.snp.centerY)
            make.width.equalTo(ballSize)
            make.height.equalTo(ballSize)
        }
        
        rightBall.snp.makeConstraints { make in
            make.centerX.equalTo(sliderBar.snp.leading).offset(rightPoint)
            make.centerY.equalTo(sliderBar.snp.centerY)
            make.width.equalTo(ballSize)
            make.height.equalTo(ballSize)
        }
    }
    
    private func configUI() {
        sliderBar.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        sliderBar.layer.cornerRadius = 3
        
        rangeStick.backgroundColor = UIColor.picoBlue
        
        [leftBall, rightBall].forEach { ball in
            ball.image = UIImage(systemName: "circle.fill")
            ball.tintColor = .white
            ball.layer.shadowColor = UIColor.gray.cgColor
            ball.layer.shadowOffset = CGSize(width: 2, height: 2)
            ball.layer.shadowOpacity = 1
            ball.frame = CGRect(x: 0, y: 0, width: ballSize, height: ballSize)
            ball.layer.cornerRadius = leftBall.frame.size.width / 2
        }
    }
    
    private func configGesture() {
        let leftBallPanGesture = UIPanGestureRecognizer(target: self, action: #selector(leftBallPan(_:)))
        leftBall.addGestureRecognizer(leftBallPanGesture)
        leftBall.isUserInteractionEnabled = true
        
        let rightBallPanGesture = UIPanGestureRecognizer(target: self, action: #selector(rightBallPan(_:)))
        rightBall.addGestureRecognizer(rightBallPanGesture)
        rightBall.isUserInteractionEnabled = true
    }
    
    private func moveBall(gesture: UIPanGestureRecognizer, ball: UIImageView) {
        let translation = gesture.translation(in: ball)
        let newCenterX = initialCenter.x + translation.x
        
        switch gesture.state {
        case .began:
            initialCenter = ball.center
        case .changed:
            if ball == leftBall {
                leftPoint = Int(newCenterX)
                if leftPoint < 0 { 
                    leftPoint = 0
                }
                if leftPoint > (rightPoint - ballSize) {
                    leftPoint = rightPoint - ballSize
                }
                updateRangeStick()
            }
            if ball == rightBall {
                rightPoint = Int(newCenterX)
                if rightPoint > Int(sliderBar.frame.width) {
                    rightPoint = Int(sliderBar.frame.width)
                }
                if rightPoint < (leftPoint + ballSize) {
                    rightPoint = leftPoint + ballSize
                }
                updateRangeStick()
            }
        case .ended:
            break
        default:
            break
        }
    }
    
    private func updateRangeStick() {
        leftBall.snp.updateConstraints { make in
            make.centerX.equalTo(sliderBar.snp.leading).offset(leftPoint)
            make.centerY.equalTo(sliderBar.snp.centerY)
            make.width.equalTo(ballSize)
            make.height.equalTo(ballSize)
        }
        
        rightBall.snp.updateConstraints { make in
            make.centerX.equalTo(sliderBar.snp.leading).offset(rightPoint)
            make.centerY.equalTo(sliderBar.snp.centerY)
            make.width.equalTo(ballSize)
            make.height.equalTo(ballSize)
        }
        
        rangeStick.snp.updateConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(sliderBar.snp.leading).offset(leftPoint)
            make.trailing.equalTo(sliderBar.snp.leading).offset(rightPoint)
            make.height.equalTo(4)
        }
    }
    
    @objc func leftBallPan(_ gesture: UIPanGestureRecognizer) {
        moveBall(gesture: gesture, ball: leftBall)
    }
    
    @objc func rightBallPan(_ gesture: UIPanGestureRecognizer) {
        moveBall(gesture: gesture, ball: rightBall)
    }
}
