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

enum FrequencyType: String, CaseIterable, Codable {
    case usually
    case nomal
    case never
    
    var name: String {
        switch self {
        case .usually:
            return "자주"
        case .nomal:
            return "가끔"
        case .never:
            return "아예 안함"
        }
    }
}

enum ReligionType: String, CaseIterable, Codable {
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
    
    var name: String {
        switch self {
        case .none:
            "무교"
        case .christianity:
            "기독교"
        case .buddhism:
            "블교"
        case .catholic:
            "천주교"
        case .wonBuddhism:
            "원불교"
        case .islam:
            "이슬람"
        case .hinduism:
            "힌두교"
        case .folk:
            "민속신앙"
        case .etc:
            "기타"
        }
    }
}

enum EducationType: String, CaseIterable, Codable {
    case middle
    case high
    case college
    case university
    case graduate
    
    var name: String {
        switch self {
        case .middle:
            "중학교"
        case .high:
            "고등학교"
        case .college:
            "전문대학교"
        case .university:
            "대학교"
        case .graduate:
            "대학원"
        }
    }
}
