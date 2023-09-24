//
//  Report.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import Foundation

struct Report: Codable {
    var id: String = UUID().uuidString
    let reportedId: String
    let reason: String
    let reportedDate: Double
}
