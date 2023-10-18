//
//  Block.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import Foundation

struct Block: Codable {
    let userId: String
    var sendBlock: [BlockInfo]?
    var recivedBlock: [BlockInfo]?
    
    struct BlockInfo: Codable {
        var id: String {
            return userId
        }
        let userId: String
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
        let createdDate: Double?
    }
}
