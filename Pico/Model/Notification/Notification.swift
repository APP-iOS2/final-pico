//
//  Notification.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import Foundation

// struct Notification: Codable {
//    let userId: String
//    let isNotification: Bool
//    let notiInfos: [NotiInfo]
//    
//    struct NotiInfo: Codable {
//        var id: String = UUID().uuidString
//        let notiType: NotiType
//        let sendUserId: String
//        let notiDate: Double
//    }
// }

enum NotiType: String, Codable {
    case like
    case message
}

struct Noti: Codable {
    let receiveId: String // 알림 받는 사람 id
    let name: String // 보내는사람 이름
    let birth: String // 보내는사람 생년월일
    let imageUrl: String // 보내는 사람 첫번째 이미지
    let notiType: NotiType
    let mbti: MBTIType // 보내는 사람 mbti
    
    var age: Int {
        let calendar = Calendar.current
        let currentDate = Date()
        let birthdate = birth.toDate()
        let ageComponents = calendar.dateComponents([.year], from: birthdate, to: currentDate)
        return ageComponents.year ?? 0
    }
}
