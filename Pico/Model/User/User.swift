//
//  User.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import Foundation

struct User: Codable {
    var id: String = UUID().uuidString
    let mbti: MBTIType
    let phoneNumber: String
    let gender: GenderType
    let birth: String
    let nickName: String
    let location: Location
    let imageURLs: [String]
    let createdDate: Double
    
    /// 추가정보
    let subInfo: SubInfo?
    /// 나를 신고한 기록
    let reports: [Report]?
    /// 내가 차단한 기록
    let blocks: [Block]?
    
    let chuCount: Int
    let isSubscribe: Bool
}

enum GenderType: Codable {
    case male
    case female
    case etc
}
