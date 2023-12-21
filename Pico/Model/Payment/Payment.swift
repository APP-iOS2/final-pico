//
//  Payment.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import Foundation

enum PaymentType: String, Codable {
    case purchase
    case randombox
    case randomboxObtain
    case worldCup
    case mail
    case changeNickname
    case backCard
    
    var name: String {
        return self.rawValue
    }
    
    var koreaName: String {
        switch self {
        case .purchase:
            return "결제"
        case .randombox:
            return "랜덤박스"
        case .randomboxObtain:
            return "랜덤박스에서 획득"
        case .worldCup:
            return "월드컵"
        case .mail:
            return "메일 보내기"
        case .changeNickname:
            return "닉네임 변경하기"
        case .backCard:
            return "되돌리기"
        }
    }
}

struct Payment: Codable {
    let paymentInfos: [PaymentInfo]?
    
    struct PaymentInfo: Codable {
        var id: String = UUID().uuidString
        let price: Int
        let purchaseChuCount: Int
        let paymentType: PaymentType
        var purchasedDate: Double = Date().timeIntervalSince1970
    }
}
