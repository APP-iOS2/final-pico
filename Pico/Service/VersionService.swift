//
//  VersionService.swift
//  Pico
//
//  Created by LJh on 12/16/23.
//

import Foundation

final class VersionService {
    static let shared: VersionService = VersionService()
    
    var isOldVersion: Bool = false
    
    private let appleID = "6473959557"
    private let bundleID = "com.ojeomsun.pico.dev"
    lazy var appStoreOpenUrlString = "itms-apps://itunes.apple.com/app/apple-store/\(appleID)"
    
    func loadAppStoreVersion(completion: @escaping (String?) -> Void) {
        let appStoreUrl = "http://itunes.apple.com/kr/lookup?bundleId=\(bundleID)"
        
        let task = URLSession.shared.dataTask(with: URL(string: appStoreUrl)!) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let appStoreVersion = results[0]["version"] as? String {
                    completion(appStoreVersion)
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func nowVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        
        return version
    }
}
