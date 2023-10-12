//
//  MailViewModel.swift
//  Pico
//
//  Created by 양성혜 on 2023/10/05.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import FirebaseFirestore
import FirebaseFirestoreSwift

enum MailType: String, Codable {
    case send
    case receive
    
    var typeString: String {
        switch self {
        case .receive:
            return "받은 쪽지"
        case .send:
            return "보낸 쪽지"
        }
    }
}

final class MailViewModel {
    
    var mailSendList = BehaviorRelay<[Mail.MailInfo]>(value: [])
    var mailRecieveList = BehaviorRelay<[Mail.MailInfo]>(value: [])
    
    var isMailSendEmpty: Observable<Bool> {
        return mailSendList
            .map { $0.isEmpty }
    }
    
    var isMailReceiveEmpty: Observable<Bool> {
        return mailSendList
            .map { $0.isEmpty }
    }
    
    private let dbRef = Firestore.firestore()
    private let disposeBag = DisposeBag()
    
    var user: User?
    
    init() {
        loadMail()
    }
    
    func saveMailData(receiveUserId: String, message: String) {
        let senderUserId: String = UserDefaultsManager.shared.getUserData().userId
        
        let sendMessages: [String: Any] = [
            "id": UUID().uuidString,
            "sendedUserId": senderUserId,
            "receivedUserId": receiveUserId,
            "message": message,
            "sendedDate": Date().timeIntervalSince1970.toString(),
            "mailType": "send",
            "isReading": true
        ]
        
        let receiveMessages: [String: Any] = [
            "id": UUID().uuidString,
            "sendedUserId": senderUserId,
            "receivedUserId": receiveUserId,
            "message": message,
            "sendedDate": Date().timeIntervalSince1970.toString(),
            "mailType": "receive",
            "isReading": false
        ]
        
        // 보내는 사람
        dbRef.collection(Collections.mail.name).document(senderUserId).setData(
            [
                "userId": senderUserId,
                "sendMailInfo": FieldValue.arrayUnion([sendMessages])
            ], merge: true) { error in
                if let error = error {
                    print("평가 업데이트 에러: \(error)")
                } else {
                    print("평가 업데이트 성공")
                }
            }
        
        // 받는 사람
        dbRef.collection(Collections.mail.name).document(receiveUserId).setData(
            [
                "userId": receiveUserId,
                "receiveMailInfo": FieldValue.arrayUnion([receiveMessages])
            ], merge: true) { error in
                if let error = error {
                    print("평가 업데이트 에러: \(error)")
                } else {
                    print("평가 업데이트 성공")
                }
            }
    }
    
    func loadMail() {
        
        FirestoreService.shared.loadDocumentRx(collectionId: .mail,
                                               documentId: UserDefaultsManager.shared.getUserData().userId,
                                               dataType: Mail.self)
            .map { mail -> [Mail.MailInfo] in
                if let mail = mail {
                    return mail.sendMailInfo ?? []
                }
                return []
            }
            .map({ mailInfos in
                print("mailInfos: \(mailInfos.filter { $0.mailType == .send })")
                return mailInfos.filter { $0.mailType == .send }
            })
            .bind(to: mailSendList)
            .disposed(by: disposeBag)
        
        FirestoreService.shared.loadDocumentRx(collectionId: .mail,
                                               documentId: UserDefaultsManager.shared.getUserData().userId,
                                               dataType: Mail.self)
            .map { mail -> [Mail.MailInfo] in
                if let mail = mail {
                    return mail.receiveMailInfo ?? []
                }
                return []
            }
            .map({ mailInfos in
                print("mailInfos: \(mailInfos.filter { $0.mailType == .receive })")
                return mailInfos.filter { $0.mailType == .receive }
            })
            .bind(to: mailRecieveList)
            .disposed(by: disposeBag)
        
        print("sendlist: \(mailSendList.value)")
        print("receivelist:\(mailRecieveList.value)")
    }
    
    func getUser(userId: String, completion: @escaping () -> ()) {
        DispatchQueue.global().async {
            self.dbRef.collection(Collections.users.name).document(userId)
                .getDocument(as: User.self) { result in
                switch result {
                case .success(let user):
                    self.user = user
                    completion()
                case .failure(let error):
                    print("Error decoding room: \(error)")
                }
            }
        }
    }
}
