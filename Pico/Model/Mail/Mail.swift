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
        let id: String = UUID().uuidString
        let sendedUserId: String
        let receivedUserId: String
        let message: String
        let sendedDate: String
        let mailType: MailType
        let isReading: Bool
    }
}
    /*
     struct Mail: Codable {
     let userId: String
     let mailInfo: [MailInfo]
     
     struct MailInfo: Codable {
     var id: String = UUID().uuidString
     let sendedUserId: String
     let receivedUserId: String
     let messages: [Message]
     }
     
     struct Message: Codable {
     var id: String = UUID().uuidString
     let message: String
     let sendedDate: String
     }
     }
     */

