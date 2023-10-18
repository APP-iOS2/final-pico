//
//  Bundle+Extenstions.swift
//  Pico
//
//  Created by 방유빈 on 2023/10/18.
//

import Foundation

extension Bundle {
    var notificationKey: String {
        guard let file = self.path(forResource: "APIKeys", ofType: "plist") else { return "" }
        
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        
        guard let key = resource["NOTIFICATION_KEY"] as? String else {
            fatalError("KEY를 찾을수없음")
        }
        return key
    }
}
