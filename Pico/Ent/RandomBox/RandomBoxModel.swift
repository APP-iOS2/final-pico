//
//  RandomBoxModel.swift
//  Pico
//
//  Created by 오영석 on 2023/09/25.
//

import Foundation

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

func getRandomValue() -> Int {
    let randomValue = Int.random(in: 1...100)
    
    switch randomValue {
    case 1...35:
        return randomBoxDummy[0].first
    case 36...55:
        return randomBoxDummy[0].second
    case 56...80:
        return randomBoxDummy[0].third
    case 81...99:
        return randomBoxDummy[0].fourth
    default:
        return randomBoxDummy[0].fifth
    }
}
