//
//  Mail.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import Foundation

struct Mail: Codable {
    let userId: String
    var sendMailInfo: [MailInfo]?
    var receiveMailInfo: [MailInfo]?
    
    struct MailInfo: Codable {
        var id: String = UUID().uuidString
        let sendedUserId: String
        let receivedUserId: String
        let mailType: MailType
        let message: String
        let sendedDate: String
        let isReading: Bool
    }
}

enum MailType: String, Codable {
    case send
    case receive
    
    var typeString: String {
        switch self {
        case .receive:
            return "받은 쪽지"
        case .send:
            return "보낸 쪽지"
        }
    }
}
