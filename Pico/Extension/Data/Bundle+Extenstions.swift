//
//  Bundle+Extenstions.swift
//  Pico
//
//  Created by 방유빈 on 2023/10/18.
//

import Foundation

enum APIKey: String {
    case FirebaseAPIKeys
    case NaverAPIKeys
    
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
        guard let file = self.path(forResource: APIKey.NaverAPIKeys.name, ofType: "plist") else { return "" }
        
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        
        guard let key = resource["TEST_AUTH_NUM"] as? String else {
            fatalError("KEY를 찾을수없음")
        }
        return key
    }
    
    var testPhoneNumber: String {
        guard let file = self.path(forResource: APIKey.NaverAPIKeys.name, ofType: "plist") else { return "" }
        
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        
        guard let key = resource["TEST_PHONE_NUMBER"] as? String else {
            fatalError("KEY를 찾을수없음")
        }
        return key
    }
    
    var senderPhoneNumber: String {
        guard let file = self.path(forResource: APIKey.NaverAPIKeys.name, ofType: "plist") else { return "" }
        
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        
        guard let key = resource["SENDER_PHONE_NUMBER"] as? String else {
            fatalError("KEY를 찾을수없음")
        }
        return key
    }
    
    var accessKey: String {
        guard let file = self.path(forResource: APIKey.NaverAPIKeys.name, ofType: "plist") else { return "" }
        
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        
        guard let key = resource["ACCESS_KEY"] as? String else {
            fatalError("KEY를 찾을수없음")
        }
        return key
    }
    
    var secretKey: String {
        guard let file = self.path(forResource: APIKey.NaverAPIKeys.name, ofType: "plist") else { return "" }
        
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        
        guard let key = resource["SECRET_KEY"] as? String else {
            fatalError("KEY를 찾을수없음")
        }
        return key
    }
    
    var serviceId: String {
        guard let file = self.path(forResource: APIKey.NaverAPIKeys.name, ofType: "plist") else { return "" }
        
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        
        guard let key = resource["SERVICE_ID"] as? String else {
            fatalError("KEY를 찾을수없음")
        }
        return key
    }
}
