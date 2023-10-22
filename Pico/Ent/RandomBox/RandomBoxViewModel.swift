//
//  RandomBoxViewModel.swift
//  Pico
//
//  Created by 오영석 on 2023/09/25.
//
import Foundation
import UIKit

struct RandomBox {
    let first: Int
    let second: Int
    let third: Int
    let fourth: Int
    let fifth: Int
}

var randomBoxDummy: [RandomBox] = [
    RandomBox(first: 1, second: 5, third: 10, fourth: 25, fifth: 50),
    RandomBox(first: 10, second: 15, third: 25, fourth: 80, fifth: 200)
]

struct RandomPercent {
    let totalProbability = 100
    let firstRange = 1...15
    let secondRange = 16...66
    let thirdRange = 67...95
    let fourthRange = 96...98
    let fifthRange = 99...100
}

final class RandomBoxViewModel {
    let randomPercent = RandomPercent()
    private var obtainedChu: Int = 0
    
    func getRandomValue(index: Int) -> Int {
        let randomValue = Int.random(in: 1...100)
        
        switch randomValue {
        case randomPercent.firstRange:
            return randomBoxDummy[index].first
        case randomPercent.secondRange:
            return randomBoxDummy[index].second
        case randomPercent.thirdRange:
            return randomBoxDummy[index].third
        case randomPercent.fourthRange:
            return randomBoxDummy[index].fourth
        default:
            return randomBoxDummy[index].fifth
        }
    }
    
    func shake(view: UIView, duration: CFTimeInterval = 0.5, repeatCount: Float = 3, completion: (() -> Void)? = nil) {
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.duration = duration
        animation.values = [-0.15, 0.15, -0.15]
        animation.repeatCount = repeatCount

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?()
        }

        view.layer.add(animation, forKey: "shake")

        CATransaction.commit()
    }
    
    func obtainChu(with randomValue: Int, number: Int) {
        obtainedChu += randomValue * number
    }
    
    func getObtainedChu() -> Int {
        return obtainedChu
    }
    
    func boxInfo() -> String {
        var result = ""
        
        for randomBox in randomBoxDummy {
            let values = [
                randomBox.first,
                randomBox.second,
                randomBox.third,
                randomBox.fourth,
                randomBox.fifth
            ]
            let infoTextArray = values.map { "\($0)츄" }
            
            if result.isEmpty {
                result += "일반 상자 : \(infoTextArray.joined(separator: ", "))"
            } else {
                result += "\n고급 상자 : \(infoTextArray.joined(separator: ", "))"
            }
        }
        return result
    }
}
