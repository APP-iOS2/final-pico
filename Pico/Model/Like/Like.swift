//
//  Like.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import Foundation

struct Like: Codable {
    let userId: String
    var sendedlikes: [LikeInfo]?
    var recivedlikes: [LikeInfo]?
    
    struct LikeInfo: Codable {
//        var id: String = UUID().uuidString
        let likedUserId: String
        let likeType: LikeType
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
    }

    enum LikeType: String, Codable {
        case like
        case dislike
        case matching
        
        var nameString: String {
            return self.rawValue.uppercased()
        }
    }
}
