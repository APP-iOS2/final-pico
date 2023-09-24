//
//  Like.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import Foundation

struct Like: Codable {
    let userId: String
    let sendedlikes: [LikeInfo]?
    let recivedlikes: [LikeInfo]?
    
    struct LikeInfo: Codable {
        var id: String = UUID().uuidString
        let likedUserId: String
        let likeType: LikeType
        let createdDate: Double
    }

    enum LikeType: Codable {
        case like
        case dislike
    }
}
