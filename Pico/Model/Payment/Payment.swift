//
//  Payment.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import Foundation

struct Payment: Codable {
    let userId: String
    let purchases: [Purchase]
    
    struct Purchase: Codable {
        var id: String = UUID().uuidString
        let price: Int
        let purchaseChuCount: Int
        let purchasedDate: Double
    }
}
