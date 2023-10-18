//
//  RandomBoxModel.swift
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
    RandomBox(first: 0, second: 2, third: 2, fourth: 3, fifth: 100)
]

struct RandomPercent {
    let totalProbability = 100
    let firstRange = 1...35
    let secondRange = 36...55
    let thirdRange = 56...80
    let fourthRange = 81...99
}

final class RandomBoxManager {
    let randomPercent = RandomPercent()

    func getRandomValue() -> Int {
        let randomValue = Int.random(in: 1...100)

        switch randomValue {
        case randomPercent.firstRange:
            return randomBoxDummy[0].first
        case randomPercent.secondRange:
            return randomBoxDummy[0].second
        case randomPercent.thirdRange:
            return randomBoxDummy[0].third
        case randomPercent.fourthRange:
            return randomBoxDummy[0].fourth
        default:
            return randomBoxDummy[0].fifth
        }
    }

    func getProbabilityInfo() -> [Int] {
        return [
            randomPercent.firstRange.count * 100 / randomPercent.totalProbability,
            randomPercent.secondRange.count * 100 / randomPercent.totalProbability,
            randomPercent.thirdRange.count * 100 / randomPercent.totalProbability,
            randomPercent.fourthRange.count * 100 / randomPercent.totalProbability,
            (randomPercent.totalProbability - randomPercent.fourthRange.upperBound + 1) * 100 / randomPercent.totalProbability
        ]
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
    
    func updateChu(with randomValue: Double, number: Int) {
        _ = Int(randomValue)
    }
}
