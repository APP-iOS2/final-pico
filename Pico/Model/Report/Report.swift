//
//  Report.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import Foundation

struct Report: Codable {
    let userId: String?
    var sendReport: [ReportInfo]?
    var recivedReport: [ReportInfo]?
    
    struct ReportInfo: Codable {
        var id: String = UUID().uuidString
        let reportedUserId: String
        let reason: String
        let birth: String
        let nickName: String
        let mbti: MBTIType
        let imageURL: String
        var age: Int {
            let calendar = Calendar.current
            let currentDate = Date()
            let birthdate = birth.toDate()
            let ageComponents = calendar.dateComponents([.year], from: birthdate, to: currentDate)
            return ageComponents.year ?? 0
        }
        let createdDate: Double
    }
}

struct AdminReport: Codable {
    var id: String = UUID().uuidString
    let reportUserId: String
    let reportNickname: String
    let reportedUserId: String
    let reportedNickname: String
    let reason: String
    let birth: String
    let mbti: MBTIType
    let imageURL: String
    var age: Int {
        let calendar = Calendar.current
        let currentDate = Date()
        let birthdate = birth.toDate()
        let ageComponents = calendar.dateComponents([.year], from: birthdate, to: currentDate)
        return ageComponents.year ?? 0
    }
    let createdDate: Double
}
