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

enum MailType: String {
    case send = "보낸 쪽지"
    case receive = "받은 쪽지"
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
    
    
    private var itemsPerPage: Int = 10
    var lastDocumentSnapshot: DocumentSnapshot?
    var user: User?
    
    init() {
        loadMail()
    }
    
    func saveMailData(receiveUserId: String, message: String) {
        let senderUserId: String = UserDefaultsManager.shared.getUserData().userId
        let messages: [String: Any] = [
            "messageId": UUID().uuidString,
            "sendedUserId": senderUserId,
            "receivedUserId": receiveUserId,
            "message": message,
            "sendedDate": Date().timeIntervalSince1970.toString(),
            "isReading": false
        ]
        
        // 보내는 사람
        dbRef.collection(Collections.mail.name).document(senderUserId).setData(
            [
                "userId": senderUserId,
                "sendMailInfo": [
                    "messages": FieldValue.arrayUnion([messages])
                ]
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
                "receiveMailInfo": [
                    "messages": FieldValue.arrayUnion([messages])
                ]
            ], merge: true) { error in
                if let error = error {
                    print("평가 업데이트 에러: \(error)")
                } else {
                    print("평가 업데이트 성공")
                }
            }
    }
    
    func loadMail() {
        
        FirestoreService.shared.loadDocumentRx(collectionId: .mail, documentId: UserDefaultsManager.shared.getUserData().userId, dataType: Mail.self)
            .map { mail -> [Mail.MailInfo] in
                if let mail = mail {
                    return mail.sendMailInfo ?? []
                }
                return []
            }
            .map({ mailInfos in
                return mailInfos.filter { $0.mailType == .send }
            })
            .bind(to: mailSendList)
            .disposed(by: disposeBag)
        
        FirestoreService.shared.loadDocumentRx(collectionId: .mail, documentId: UserDefaultsManager.shared.getUserData().userId, dataType: Mail.self)
            .map { mail -> [Mail.MailInfo] in
                if let mail = mail {
                    return mail.receiveMailInfo ?? []
                }
                return []
            }
            .map({ mailInfos in
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
