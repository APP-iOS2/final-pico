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
    // 19 이상부터
    private var sliderMinValue = 19
    // 62 미만까지
    private var sliderMaxValue = 62
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
        titleLabel.text = "title"
        titleLabel.font = .picoSubTitleFont
        
        sliderBar.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        sliderBar.layer.cornerRadius = 2
        
        rangeBar.backgroundColor = UIColor.picoBlue
        if rightBallValue > 60 {
            valueLabel.text = ("\(String(leftBallValue))세 ~ 60세 +")
        } else {
            valueLabel.text = ("\(String(leftBallValue))세 ~ \(String(rightBallValue))세")
        }
        valueLabel.textAlignment = .right
        valueLabel.font = .picoSubTitleFont
        valueLabel.textColor = .picoBlue
        
        [leftBall, rightBall].forEach { ball in
            ball.image = UIImage(systemName: "circle.fill")
            ball.tintColor = .picoBlue
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
                if leftPoint < 5 {
                    leftPoint = 5
                }
                if leftPoint > (rightPoint - ballSize + 5) {
                    leftPoint = rightPoint - ballSize + 5
                }
                updateRangeStick()
                leftBallValue = (leftPoint) * (sliderMaxValue - sliderMinValue) / Int(sliderBar.frame.width) + sliderMinValue
                if leftBallValue >= rightBallValue {
                    leftBallValue = rightBallValue - 1
                }
                if rightBallValue > 60 {
                    valueLabel.text = ("\(String(leftBallValue))세 ~ 60세 +")
                    HomeViewModel.filterAgeMin = leftBallValue
                    HomeViewModel.viewIsUpdate = true
                    UserDefaults.standard.set(HomeViewModel.filterAgeMin, forKey: UserDefaultsManager.Key.filterAgeMin.rawValue)
                } else {
                    valueLabel.text = ("\(String(leftBallValue))세 ~ \(String(rightBallValue))세")
                    HomeViewModel.filterAgeMin = leftBallValue
                    HomeViewModel.viewIsUpdate = true
                    UserDefaults.standard.set(HomeViewModel.filterAgeMin, forKey: UserDefaultsManager.Key.filterAgeMin.rawValue)
                }
            }
            if ball == rightBall {
                rightPoint = Int(newCenterX)
                if rightPoint > Int(sliderBar.frame.width) - 5 {
                    rightPoint = Int(sliderBar.frame.width) - 5
                }
                if rightPoint < (leftPoint + ballSize - 5) {
                    rightPoint = leftPoint + ballSize - 5
                }
                updateRangeStick()
                rightBallValue = (rightPoint) * (sliderMaxValue - sliderMinValue) / Int(sliderBar.frame.width) + sliderMinValue
                if rightBallValue > 60 {
                    valueLabel.text = ("\(String(leftBallValue))세 ~ 60세 +")
                    HomeViewModel.filterAgeMax = 61
                    HomeViewModel.viewIsUpdate = true
                    UserDefaults.standard.set(HomeViewModel.filterAgeMax, forKey: UserDefaultsManager.Key.filterAgeMax.rawValue)
                } else {
                    valueLabel.text = ("\(String(leftBallValue))세 ~ \(String(rightBallValue))세")
                    HomeViewModel.filterAgeMax = rightBallValue
                    HomeViewModel.viewIsUpdate = true
                    UserDefaults.standard.set(HomeViewModel.filterAgeMax, forKey: UserDefaultsManager.Key.filterAgeMax.rawValue)
                }
            }
        case .ended:
            break
        default:
            break
        }
    }
    
    private func calculatePointFromValue(_ value: Int) -> Int {
        if value > 60 {
            return Int(sliderBar.frame.width) - 5
        }
        return Int((Double(value - sliderMinValue) / Double(sliderMaxValue - sliderMinValue)) * Double(sliderBar.frame.width))
    }
    
    private func updateRangeStick() {
        if leftPoint == 0 {
            leftPoint = 5
        }
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
