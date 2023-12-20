//
//  Chatting.swift
//  Pico
//
//  Created by 양성혜 on 2023/12/16.
//

import Foundation

struct Room: Codable {
    var userId: String
    var room: [RoomInfo]?
    
    struct RoomInfo: Codable {
        var roomId: String
        let opponentId: String
        let lastMessage: String
        let sendedDate: Double
    }
}

struct Chatting: Codable {
    var userId: String
    var userChatting: [ChattingInfo]?
    
    struct ChattingInfo: Codable {
        var id: String = UUID().uuidString
        let roomId: String
        let sendUserId: String
        let receiveUserId: String
        let message: String
        let sendedDate: Double
        let isReading: Bool
    }
}

enum ChattingSendType: Codable {
    case chatting
    case matching
}
