//
//  UserDefaultsManager.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import Foundation

final class UserDefaultsManager {
    enum Key: String, CaseIterable {
        case userId, nickName, mbti, imageURL, birth
        case latitude, longitude
        case filterGender, filterMbti, filterDistance, filterAgeMin, filterAgeMax
        case chuCount
        case dontWatchAgain
    }
    
    static let shared: UserDefaultsManager = UserDefaultsManager()
    
    func removeAll() {
        Key.allCases.forEach {
            UserDefaults.standard.removeObject(forKey: $0.rawValue)
        }
    }
    
    func setUserData(userData: User) {
        UserDefaults.standard.setValue(userData.id, forKey: Key.userId.rawValue)
        UserDefaults.standard.setValue(userData.nickName, forKey: Key.nickName.rawValue)
        UserDefaults.standard.setValue(userData.mbti.rawValue, forKey: Key.mbti.rawValue)
        
        if let imageURL = userData.imageURLs[safe: 0] {
            UserDefaults.standard.setValue(imageURL, forKey: Key.imageURL.rawValue)
        }
        UserDefaults.standard.setValue(userData.birth, forKey: Key.birth.rawValue)
        UserDefaults.standard.setValue(userData.location.latitude, forKey: Key.latitude.rawValue)
        UserDefaults.standard.setValue(userData.location.longitude, forKey: Key.longitude.rawValue)
        
        UserDefaults.standard.setValue(userData.chuCount, forKey: Key.chuCount.rawValue)
    }
    
    func isLogin() -> Bool {
           UserDefaults.standard.string(forKey: Key.userId.rawValue) != nil ? true : false
       }
    
    func getUserData() -> CurrentUser {
        let userId = UserDefaults.standard.string(forKey: Key.userId.rawValue) ?? "없음"
        let nickName = UserDefaults.standard.string(forKey: Key.nickName.rawValue) ?? "없음"
        let mbti = UserDefaults.standard.string(forKey: Key.mbti.rawValue) ?? "없음"
        let imageURL = UserDefaults.standard.string(forKey: Key.imageURL.rawValue) ?? "없음"
        let birth = UserDefaults.standard.string(forKey: Key.birth.rawValue) ?? "없음"
        let latitude = UserDefaults.standard.double(forKey: Key.latitude.rawValue)
        let longitude = UserDefaults.standard.double(forKey: Key.longitude.rawValue)
        return CurrentUser(userId: userId, nickName: nickName, mbti: mbti, imageURL: imageURL, birth: birth, latitude: latitude, longitude: longitude)
    }
    
    func getChuCount() -> Int {
        return UserDefaults.standard.integer(forKey: Key.chuCount.rawValue)
    }
    
    func updateChuCount(_ chuCount: Int) {
        UserDefaults.standard.setValue(chuCount, forKey: Key.chuCount.rawValue)
    }
}
