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
    private let rangeBar = UIView()
    private let leftBall = UIImageView()
    private let rightBall = UIImageView()
    private let ballSize = 14
    
    private var initialCenter = CGPoint()
    private var leftPoint = Int()
    private var rightPoint = Int()
    private var valueLabel = UILabel()
    private var layoutIsCheck = false
    private var sliderMinValue = 19
    private var sliderMaxValue = 61
    private var leftBallValue = HomeViewModel.filterAgeMin
    private var rightBallValue = HomeViewModel.filterAgeMax
    var titleLabel = UILabel()
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if layoutIsCheck == false {
            leftPoint = calculatePointFromValue(leftBallValue)
            rightPoint = calculatePointFromValue(rightBallValue)
            updateRangeStick()
            layoutIsCheck = true
        }
    }
    
    private func addSubView() {
        addSubview([sliderBar, rangeBar, leftBall, rightBall, valueLabel, titleLabel])
    }
    
    private func makeConstraints() {
        sliderBar.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(4)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.bottom.equalTo(sliderBar.snp.top).offset(-15)
            make.width.equalTo(50)
            make.height.equalTo(30)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.bottom.equalTo(sliderBar.snp.top).offset(-15)
            make.width.equalTo(120)
            make.height.equalTo(30)
        }
        
        rangeBar.snp.updateConstraints { make in
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
        titleLabel.text = "제목"
        titleLabel.font = .picoSubTitleFont
        
        sliderBar.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        sliderBar.layer.cornerRadius = 3
        
        rangeBar.backgroundColor = UIColor.picoBlue
        
        valueLabel.text = ("\(String(leftBallValue))세 ~ \(String(rightBallValue))세")
        valueLabel.textAlignment = .right
        valueLabel.font = .picoSubTitleFont
        valueLabel.textColor = .picoBlue
        
        [leftBall, rightBall].forEach { ball in
            ball.image = UIImage(systemName: "circle.fill")
            ball.tintColor = .picoBlue
            //            ball.layer.shadowColor = UIColor.gray.cgColor
            //            ball.layer.shadowOffset = CGSize(width: 2, height: 2)
            //            ball.layer.shadowOpacity = 1
            //            ball.frame = CGRect(x: 0, y: 0, width: ballSize, height: ballSize)
            //            ball.layer.cornerRadius = leftBall.frame.size.width / 2
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
                if leftPoint > (rightPoint - ballSize + 5) {
                    leftPoint = rightPoint - ballSize + 5
                }
                updateRangeStick()
                leftBallValue = (leftPoint + ballSize / 2) * (sliderMaxValue - sliderMinValue) / Int(sliderBar.frame.width) + sliderMinValue
                if leftBallValue >= rightBallValue {
                    leftBallValue = rightBallValue - 1
                }
                valueLabel.text = ("\(String(leftBallValue))세 ~ \(String(rightBallValue))세")
                HomeViewModel.filterAgeMin = leftBallValue
            }
            if ball == rightBall {
                rightPoint = Int(newCenterX)
                if rightPoint > Int(sliderBar.frame.width) {
                    rightPoint = Int(sliderBar.frame.width)
                }
                if rightPoint < (leftPoint + ballSize - 5) {
                    rightPoint = leftPoint + ballSize - 5
                }
                updateRangeStick()
                rightBallValue = (rightPoint + ballSize / 2) * (sliderMaxValue - sliderMinValue) / Int(sliderBar.frame.width) + sliderMinValue
                if rightBallValue > 60 {
                    valueLabel.text = ("\(String(leftBallValue))세 ~ 60세 +")
                    HomeViewModel.filterAgeMax = 61
                } else {
                    valueLabel.text = ("\(String(leftBallValue))세 ~ \(String(rightBallValue))세")
                    HomeViewModel.filterAgeMax = rightBallValue
                }
            }
        case .ended:
            break
        default:
            break
        }
    }
    
    private func calculatePointFromValue(_ value: Int) -> Int {
        return Int((CGFloat(value - sliderMinValue) / CGFloat(sliderMaxValue - sliderMinValue)) * (sliderBar.frame.width - CGFloat(ballSize)))
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
        
        rangeBar.snp.updateConstraints { make in
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
