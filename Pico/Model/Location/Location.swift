//
//  Location.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import Foundation

struct Location: Codable {
    let address: String
    /// 위도
    let latitude: Double
    /// 경도
    let longitude: Double
}
