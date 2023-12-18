//
//  Chatting.swift
//  Pico
//
//  Created by 양성혜 on 2023/12/16.
//

import Foundation

struct Chatting: Codable {
    let chatId: String
    var userChatting: [ChattingInfo]?
    
    struct ChattingInfo: Codable {
        var id: String = UUID().uuidString
        let roomID: String
        let sendUserId: String
        let receiveUserId: String
        let message: String
        let sendedDate: Double
        let isReading: Bool
    }
}
