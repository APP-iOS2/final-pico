//
//  SubInfo.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import Foundation

struct SubInfo: Codable {
    let intro: String
    let height: Int
    let drinkStatus: FrequencyType
    let smokeStatus: FrequencyType
    let religion: ReligionType
    let education: EducationType
    let job: String
    
    let hobbies: [String]
    let personalities: [String]
    let favoriteMBTIs: [MBTIType]
}

enum FrequencyType: String, Codable {
    case usually
    case nomal
    case never
}

enum ReligionType: String, Codable {
    /// 무교
    case none
    /// 기독교
    case christianity
    /// 불교
    case buddhism
    /// 천주교
    case catholic
    /// 원불교
    case wonBuddhism
    /// 이슬람
    case islam
    /// 힌두교
    case hinduism
    /// 민속신앙
    case folk
    /// 기타
    case etc
}

enum EducationType: String, Codable {
    case middle
    case high
    case college
    case university
    case graduate
}
