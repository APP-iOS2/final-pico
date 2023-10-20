//
//  Payment.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import Foundation

struct Payment: Codable {
    var id: String = UUID().uuidString
    let price: Int
    let purchaseChuCount: Int
    var purchasedDate: Double = Date().timeIntervalSince1970
}
