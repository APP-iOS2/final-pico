//
//  Notification.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import Foundation

struct Notification: Codable {
    let userId: String
    let isNotification: Bool
    let notiInfos: [NotiInfo]
    
    struct NotiInfo: Codable {
        var id: String = UUID().uuidString
        let notiType: NotiType
        let sendUserId: String
        let notiDate: Double
    }
}

enum NotiType: String, Codable {
    case like
    case message
}
