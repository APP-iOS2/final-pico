//
//  UserDefaultsManager.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import Foundation

final class UserDefaultsManager {
    enum Key: String, CaseIterable {
        case userId, nickName, mbti, imageURL
        case latitude, longitude
    }
    
    static let shared: UserDefaultsManager = UserDefaultsManager()
    
    func removeAll() {
        Key.allCases.forEach {
            UserDefaults.standard.removeObject(forKey: $0.rawValue)
        }
    }
}
