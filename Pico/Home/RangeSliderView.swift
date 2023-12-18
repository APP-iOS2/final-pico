//
//  RangeSliderView.swift
//  Pico
//
//  Created by 임대진 on 10/12/23.
//

import UIKit
import SnapKit

final class RangeSliderView: UIView {
    private let backgroundBar = UIView()
    private let sliderBar = UIView()
    private let rangeBar = UIView()
    private let leftBall = UIImageView()
    private let rightBall = UIImageView()
    private let thumbSize = 18
    
    private var initialCenter = CGPoint()
    private var minPoint = Int()
    private var maxPoint = Int()
    private var valueLabel = UILabel()
    private var layoutIsCheck = false
    // 19 이상부터
    private var sliderMinValue = 19
    // 61 이하까지
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
            minPoint = calculatePointFromValue(leftBallValue)
            maxPoint = calculatePointFromValue(rightBallValue)
            updateRangeStick()
            layoutIsCheck = true
        }
    }
    
    private func addSubView() {
        addSubview([backgroundBar, sliderBar, rangeBar, leftBall, rightBall, valueLabel, titleLabel])
    }
    
    private func makeConstraints() {
        backgroundBar.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(1)
            make.trailing.equalToSuperview().inset(1)
            make.height.equalTo(4)
        }
        
        sliderBar.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalTo(backgroundBar).offset(thumbSize / 3)
            make.trailing.equalTo(backgroundBar).inset(thumbSize / 3)
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
            make.leading.equalTo(sliderBar.snp.leading).offset(minPoint)
            make.trailing.equalTo(sliderBar.snp.leading).offset(maxPoint)
            make.height.equalTo(4)
        }
        
        leftBall.snp.makeConstraints { make in
            make.centerX.equalTo(sliderBar.snp.leading).offset(minPoint)
            make.centerY.equalTo(sliderBar.snp.centerY)
            make.width.equalTo(thumbSize)
            make.height.equalTo(thumbSize)
        }
        
        rightBall.snp.makeConstraints { make in
            make.centerX.equalTo(sliderBar.snp.leading).offset(maxPoint)
            make.centerY.equalTo(sliderBar.snp.centerY)
            make.width.equalTo(thumbSize)
            make.height.equalTo(thumbSize)
        }
    }
    
    private func configUI() {
        titleLabel.text = "title"
        titleLabel.font = .picoSubTitleFont
        
        backgroundBar.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        backgroundBar.layer.cornerRadius = 2
        
        sliderBar.backgroundColor = UIColor.clear
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
        var ball = ball
        let translation = gesture.translation(in: ball)
        let newCenterX = initialCenter.x + translation.x
        
        switch gesture.state {
        case .began:
            initialCenter = ball.center
        case .changed:
            if ball == leftBall {
                minPoint = Int(newCenterX)
                if minPoint < 0 {
                    minPoint = 0
                }
                if minPoint >= maxPoint {
                    minPoint = maxPoint
                }
                updateRangeStick()
                leftBallValue = (minPoint) * (sliderMaxValue - sliderMinValue) / Int(sliderBar.frame.width) + sliderMinValue
                if leftBallValue >= rightBallValue {
                    leftBallValue = rightBallValue
                }
                if rightBallValue > 60 {
                    valueLabel.text = ("\(String(leftBallValue))세 ~ 60세 +")
                    HomeViewModel.filterAgeMin = leftBallValue
                    HomeFilterViewController.filterChangeState = true
                    UserDefaults.standard.set(HomeViewModel.filterAgeMin, forKey: UserDefaultsManager.Key.filterAgeMin.rawValue)
                } else {
                    valueLabel.text = ("\(String(leftBallValue))세 ~ \(String(rightBallValue))세")
                    HomeViewModel.filterAgeMin = leftBallValue
                    HomeFilterViewController.filterChangeState = true
                    UserDefaults.standard.set(HomeViewModel.filterAgeMin, forKey: UserDefaultsManager.Key.filterAgeMin.rawValue)
                }
            }
            if ball == rightBall {
                maxPoint = Int(newCenterX)
                if maxPoint > Int(sliderBar.frame.width) {
                    maxPoint = Int(sliderBar.frame.width)
                }
                if maxPoint <= minPoint {
                    maxPoint = minPoint
                }
                updateRangeStick()
                rightBallValue = (maxPoint) * (sliderMaxValue - sliderMinValue) / Int(sliderBar.frame.width) + sliderMinValue
                if leftBallValue >= rightBallValue {
                    leftBallValue = rightBallValue
                }
                if rightBallValue > 60 {
                    valueLabel.text = ("\(String(leftBallValue))세 ~ 60세 +")
                    HomeViewModel.filterAgeMax = 61
                    HomeFilterViewController.filterChangeState = true
                    UserDefaults.standard.set(HomeViewModel.filterAgeMax, forKey: UserDefaultsManager.Key.filterAgeMax.rawValue)
                } else {
                    valueLabel.text = ("\(String(leftBallValue))세 ~ \(String(rightBallValue))세")
                    HomeViewModel.filterAgeMax = rightBallValue
                    HomeFilterViewController.filterChangeState = true
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
        leftBall.snp.updateConstraints { make in
            make.centerX.equalTo(sliderBar.snp.leading).offset(minPoint)
            make.centerY.equalTo(sliderBar.snp.centerY)
            make.width.equalTo(thumbSize)
            make.height.equalTo(thumbSize)
        }
        
        rightBall.snp.updateConstraints { make in
            make.centerX.equalTo(sliderBar.snp.leading).offset(maxPoint)
            make.centerY.equalTo(sliderBar.snp.centerY)
            make.width.equalTo(thumbSize)
            make.height.equalTo(thumbSize)
        }
        
        rangeBar.snp.updateConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(sliderBar.snp.leading).offset(minPoint)
            make.trailing.equalTo(sliderBar.snp.leading).offset(maxPoint)
            make.height.equalTo(4)
        }
    }
    
    @objc func leftBallPan(_ gesture: UIPanGestureRecognizer) {
        moveBall(gesture: gesture, ball: leftBall)
        bringSubviewToFront(leftBall)
    }
    
    @objc func rightBallPan(_ gesture: UIPanGestureRecognizer) {
        moveBall(gesture: gesture, ball: rightBall)
        bringSubviewToFront(rightBall)
    }
}
