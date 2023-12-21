//
//  Stop.swift
//  Pico.admin
//
//  Created by 최하늘 on 12/15/23.
//

import Foundation

/// 정지
struct Stop: Codable {
    /// 정지된 날짜
    let createdDate: Double
    /// 정지일 수
    let during: Int
    let phoneNumber: String
    let user: User
}

enum DuringType: CaseIterable {
    case oneDay
    case threeDay
    case senvenDay
    case oneMonth
    
    /// 숫자
    var number: Int {
        switch self {
        case .oneDay:
            return 1
        case .threeDay:
            return 3
        case .senvenDay:
            return 7
        case .oneMonth:
            return 30
        }
    }
    
    /// ?일
    var name: String {
        return "\(self.number)일"
    }
}
