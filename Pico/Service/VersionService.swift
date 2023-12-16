//
//  VersionService.swift
//  Pico
//
//  Created by LJh on 12/16/23.
//

import Foundation

final class VersionService {
    static let shared: VersionService = VersionService()
    
    var isCheckVersion: Bool = false
    
    func loadAppStoreVersion(completion: @escaping (String?) -> Void) {
        let bundleID = "com.ojeomsun.pico.dev"
        let appStoreUrl = "http://itunes.apple.com/kr/lookup?bundleId=\(bundleID)"
        
        let task = URLSession.shared.dataTask(with: URL(string: appStoreUrl)!) { data, _, error in
            guard let data = data, error == nil else {
                // 네트워크 에러 등을 처리하거나, 실패 시 nil을 반환
                completion(nil)
                return
            }
            
            do {
                // JSON 데이터 파싱
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let appStoreVersion = results[0]["version"] as? String {
                    // 성공 시 가져온 버전을 전달
                    completion(appStoreVersion)
                } else {
                    // JSON 데이터 파싱 에러 시 nil을 반환
                    completion(nil)
                }
            } catch {
                // JSON 데이터 파싱 에러 시 nil을 반환
                completion(nil)
            }
        }
        
        task.resume()
    }
}
