//
//  Block.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import Foundation

struct Block: Codable {
    let blockedId: String
    let blockedDate: Double
    var id: String {
        return blockedId
    }
}
