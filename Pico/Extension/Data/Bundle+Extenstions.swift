//
//  Bundle+Extenstions.swift
//  Pico
//
//  Created by 방유빈 on 2023/10/18.
//

import Foundation

enum APIKey: String {
    case FirebaseAPIKeys
    case EmailAuthKeys
    
    var name: String {
        return self.rawValue
    }
}

extension Bundle {
    var notificationKey: String {
        guard let file = self.path(forResource: APIKey.FirebaseAPIKeys.name, ofType: "plist") else { return "" }
        
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        
        guard let key = resource["NOTIFICATION_KEY"] as? String else {
            fatalError("KEY를 찾을수없음")
        }
        return key
    }
    
    var testId: String {
        guard let file = self.path(forResource: APIKey.FirebaseAPIKeys.name, ofType: "plist") else { return "" }
        
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        
        guard let key = resource["TEST_ID"] as? String else {
            fatalError("KEY를 찾을수없음")
        }
        return key
    }
    
    var testAuthNum: String {
        guard let file = self.path(forResource: APIKey.EmailAuthKeys.name, ofType: "plist") else { return "" }
        
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        
        guard let key = resource["TEST_AUTH_NUM"] as? String else {
            fatalError("KEY를 찾을수없음")
        }
        return key
    }
    
    var testPhoneNumber: String {
        guard let file = self.path(forResource: APIKey.EmailAuthKeys.name, ofType: "plist") else { return "" }
        
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        
        guard let key = resource["TEST_PHONE_NUMBER"] as? String else {
            fatalError("KEY를 찾을수없음")
        }
        return key
    }
    
    var senderEmail: String {
        guard let file = self.path(forResource: APIKey.EmailAuthKeys.name, ofType: "plist") else { return "" }
        
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        
        guard let key = resource["SENDER_EMAIL"] as? String else {
            fatalError("KEY를 찾을수없음")
        }
        return key
    }
}
