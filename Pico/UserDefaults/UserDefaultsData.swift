//
//  UserDefaultsData.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import Foundation

final class UserDefaultsData {
    enum Key: String, CaseIterable {
        case userId, nickName, mbti, imageURL
        case latitude, longitude
    }
    
    static let shared: UserDefaultsData = UserDefaultsData()
    
    func removeAll() {
        Key.allCases.forEach {
            UserDefaults.standard.removeObject(forKey: $0.rawValue)
        }
    }
}
