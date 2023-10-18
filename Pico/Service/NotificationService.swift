//
//  NotificationService.swift
//  Pico
//
//  Created by 방유빈 on 2023/10/18.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseMessaging

enum PushNotiType {
    case like
    case message
    case matching
}

final class NotificationService {
    static let shared: NotificationService = NotificationService()
    
    func saveToken() {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("토큰 가져오기 실패 : \(error)")
                return
            } else if let token = token {
                let newToken = Token(fcmToken: token)
                if UserDefaultsManager.shared.isLogin() {
                    FirestoreService.shared.saveDocument(collectionId: .tokens, documentId: UserDefaultsManager.shared.getUserData().userId, data: newToken) { result in
                        switch result {
                        case .success(_):
                            print("토큰 저장 성공 Token: \(token)")
                        case .failure(let error):
                            print("토큰 저장 실패: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    /// 푸쉬알림 보내기
    /// userId: 알림을 받을 UserId, sendUserName: 보내는 사람(자신) 닉네임, notiType: like, message, matching
    func sendNotification(userId: String, sendUserName: String, notiType: PushNotiType) {
        let title: String = "Pico"
        var body: String = ""
        FirestoreService.shared.loadDocument(collectionId: .tokens, documentId: userId, dataType: Token.self) { result in
            switch result {
            case .success(let data):
                switch notiType {
                case .like:
                    body = "\(sendUserName)님이 좋아요를 누르셨습니다."
                case .message:
                    body = "\(sendUserName)님이 메시지를 보냈습니다."
                case .matching:
                    body = "\(sendUserName)님과 매칭이 되었습니다."
                }
                guard let token = data else { return }
                let urlString = "https://fcm.googleapis.com/fcm/send"
                let url = NSURL(string: urlString)!
                let paramString: [String: Any] = ["to": token.fcmToken,
                                                   "notification": ["title": title, "body": body],
                                                   "data": ["title": title, "body": body],
                                                   "content_available": true
                ]
                let request = NSMutableURLRequest(url: url as URL)
                request.httpMethod = "POST"
                request.httpBody = try? JSONSerialization.data(withJSONObject: paramString, options: [.prettyPrinted])
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("key=\(Bundle.main.notificationKey)", forHTTPHeaderField: "Authorization")
                
                let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, _) in
                    do {
                        if let jsonData = data {
                            if let jsonDataDict = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                                NSLog("Received data:\n\(jsonDataDict))")
                            }
                        }
                    } catch let err as NSError {
                        print(err.debugDescription)
                    }
                }
                task.resume()
                
            case .failure(let error):
                print("토큰 불러오기 실패: \(error)")
            }
        }
    }
}
