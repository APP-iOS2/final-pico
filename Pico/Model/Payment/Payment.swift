//
//  Payment.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import Foundation

enum PaymentType: Codable {
    case purchase
    case randombox
    case worldCup
    case mail
    case changeNickname
    case backCard
}

struct Payment: Codable {
//    let userId: String
    let paymentInfos: [PaymentInfo]?
    
    struct PaymentInfo: Codable {
        var id: String = UUID().uuidString
        let price: Int
        let purchaseChuCount: Int
        let paymentType: PaymentType
        var purchasedDate: Double = Date().timeIntervalSince1970
    }
}
