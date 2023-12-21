//
//  User.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import Foundation

struct User: Codable, Hashable {
    var id: String = UUID().uuidString
    let mbti: MBTIType
    let phoneNumber: String
    let gender: GenderType
    let birth: String
    let nickName: String
    var location: Location
    var imageURLs: [String]
    let createdDate: Double
    
    /// 추가정보
    var subInfo: SubInfo?
    /// 나를 신고한 기록
    var reports: [Report]?
    /// 내가 차단한 기록
    var blocks: [Block]?
    
    let chuCount: Int
    let isSubscribe: Bool
    let isOnline: Bool?
    
    static let tempUser = User(mbti: .enfj, phoneNumber: "", gender: .etc, birth: "", nickName: "", location: Location(address: "", latitude: 0.0, longitude: 0.0), imageURLs: ["", ""], createdDate: 0.0, chuCount: 0, isSubscribe: false, isOnline: false)
    
    var age: Int {
        let calendar = Calendar.current
        let currentDate = Date()
        let birthdate = birth.toDate()
        let ageComponents = calendar.dateComponents([.year], from: birthdate, to: currentDate)
        return ageComponents.year ?? 0
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum GenderType: String, Codable, CaseIterable {
    case male
    case female
    case etc
}
