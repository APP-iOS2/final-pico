//
//  Unsubscribe.swift
//  Pico.admin
//
//  Created by 최하늘 on 12/15/23.
//

import Foundation

/// 탈퇴
struct Unsubscribe: Codable {
    /// 탈퇴된 날짜
    let createdDate: Double
    let phoneNumber: String
    let user: User
}
