//
//  Chat.swift
//  Pico
//
//  Created by 최하늘 on 1/17/24.
//

import Foundation

struct ChatRoom: Codable {
    let roomInfo: [RoomInfo]
    
    struct RoomInfo: Codable {
        var roomId: String
        /// 대화상대 정보
        var opponentId: String
        var opponentNickName: String
        var opponentMbti: MBTIType
        var opponentImageURL: String
        /// 마지막 메시지
        var lastMessage: String
        var sendedDate: Double
    }
}

struct ChatDetail: Codable {
    let chatInfo: [ChatInfo]
    
    struct ChatInfo: Codable {
        /// 보낸 사람
        let sendUserId: String
        let message: String
        let sendedDate: Double
        let isReading: Bool
    }
}

enum ChatType: String, Codable {
    case send
    case receive
    
    var imageStyle: String {
        switch self {
        case .send:
            return "myChat"
        case .receive:
            return "yourChat"
        }
    }
}
