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

extension User {
    // User MockUpData
    static let userData = User(mbti: .infp, phoneNumber: "01046275953", gender: .male, birth: "0131", nickName: "희권", location: Location(address: "부천", latitude: 10, longitude: 10), imageURLs: [], createdDate: 10, subInfo: SubInfo(intro: "안녕하세요", height: 175, drinkStatus: .nomal, smokeStatus: .never, religion: .none, education: .university, job: "개발자", hobbies: ["산책", "개발"], personalities: ["말이많아요", "솔직해요"], favoriteMBTIs: [.enfj, .enfp]), reports: nil, blocks: nil, chuCount: 1000, isSubscribe: false)
}
