//
//  MailSendModel.swift
//  Pico
//
//  Created by 양성혜 on 2023/10/05.
//

import UIKit
import RxSwift
import RxRelay
import FirebaseFirestore

final class MailSendModel {
    
    private(set) var sendList: [Mail.MailInfo] = [] {
        didSet {
            if sendList.isEmpty {
                isSendEmptyPublisher.onNext(true)
            } else {
                isSendEmptyPublisher.onNext(false)
            }
        }
    }
    
    private var isSendEmptyPublisher = PublishSubject<Bool>()
    private let reloadMailTableViewPublisher = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    
    private let dbRef = Firestore.firestore()
    private var itemsPerPage: Int = Int(Screen.height * 1.5 / 90)
    var startIndex = 0
    var user: User?
    
    struct Input {
        let listLoad: Observable<Void>
        let deleteUser: Observable<String>
        let refresh: Observable<Void>
        let isSendEmptyChecked: Observable<Void>
    }
    
    struct Output {
        let sendIsEmpty: Observable<Bool>
        let reloadMailTableView: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        input.refresh
            .withUnretained(self)
            .subscribe { viewModel, _ in
                viewModel.refresh()
            }
            .disposed(by: disposeBag)
        
        input.listLoad
            .withUnretained(self)
            .subscribe { viewModel, _ in
                viewModel.loadNextMailPage()
            }
            .disposed(by: disposeBag)
        
        input.deleteUser
            .withUnretained(self)
            .subscribe { viewModel, mailId in
                viewModel.deleteMail(mailId: mailId)
            }
            .disposed(by: disposeBag)
        
        let didSendset = isSendEmptyPublisher.asObservable()
            .map { result in
                return result
            }
        
        let sendCheck = input.isSendEmptyChecked
            .withUnretained(self)
            .map { viewModel, _ -> Bool in
                if viewModel.sendList.isEmpty {
                    return true
                } else {
                    return false
                }
            }
        
        let isSendEmpty = Observable.of(didSendset, sendCheck).merge()
            .flatMapLatest { bool -> Observable<Bool> in
                return Observable.create { emitter in
                    emitter.onNext(bool)
                    return Disposables.create()
                }
            }
        
        return Output(sendIsEmpty: isSendEmpty, reloadMailTableView: reloadMailTableViewPublisher.asObservable())
    }
    
    func loadNextMailPage() {
        let ref = dbRef.collection(Collections.mail.name)
            .document(UserDefaultsManager.shared.getUserData().userId)
        
        DispatchQueue.global().async {
            ref.getDocument { [weak self] document, error in
                guard let self = self else { return }
                if let error = error {
                    print(error)
                    return
                }
                
                if let document = document, document.exists {
                    if let datas = try? document.data(as: Mail.self)
                        .sendMailInfo?.filter({ $0.mailType == .send }) {
                        if startIndex > datas.count - 1 {
                            return
                        }
                        let currentPageDatas: [Mail.MailInfo] = Array(datas[startIndex..<min(itemsPerPage, datas.count)])
                        sendList.append(contentsOf: currentPageDatas)
                        startIndex += currentPageDatas.count
                    } else {
                        print("보낸 문서를 찾을 수 없습니다.")
                    }
                }
                sendList.sort(by: {$0.sendedDate > $1.sendedDate})
                
                reloadMailTableViewPublisher.onNext(())
            }
        }
    }
    
    private func refresh() {
        let didSet = isSendEmptyPublisher
        isSendEmptyPublisher = PublishSubject<Bool>()
        sendList = []
        startIndex = 0
        isSendEmptyPublisher = didSet
        loadNextMailPage()
    }
    
    private func deleteMail(mailId: String) {
        let currentUser = UserDefaultsManager.shared.getUserData()
        
        guard let index = sendList.firstIndex(where: {
            $0.id == mailId
            
        }) else {
            return
        }
        guard let removeData: Mail.MailInfo = sendList[safe: index] else {
            print("삭제 실패: 해당 유저 정보 얻기 실패")
            return
        }
        print(index)
        sendList.remove(at: index)
        reloadMailTableViewPublisher.onNext(())
        
        DispatchQueue.global().async {
            // 마지막 꺼 삭제됨 -> 해당 필드 삭제 필요
            self.dbRef.collection(Collections.mail.name).document(currentUser.userId).updateData([
                "sendMailInfo": FieldValue.arrayRemove([removeData.asDictionary()])
            ])
        }
    }
    
    func saveMailData(receiveUser: User, message: String, type: MailSendType) {
        let senderUser = UserDefaultsManager.shared.getUserData()
        
        let sendMessages: [String: Any] = [
            "id": UUID().uuidString,
            "sendedUserId": senderUser.userId,
            "receivedUserId": receiveUser.id,
            "message": message,
            "sendedDate": Date().timeIntervalSince1970,
            "mailType": "send",
            "isReading": true
        ]
        
        let receiveMessages: [String: Any] = [
            "id": UUID().uuidString,
            "sendedUserId": senderUser.userId,
            "receivedUserId": receiveUser.id,
            "message": message,
            "sendedDate": Date().timeIntervalSince1970,
            "mailType": "receive",
            "isReading": false
        ]
        
        // 보내는 사람
        dbRef.collection(Collections.mail.name).document(senderUser.userId).setData(
            [
                "userId": senderUser.userId,
                "sendMailInfo": FieldValue.arrayUnion([sendMessages])
            ], merge: true) { error in
                if let error = error {
                    print("평가 업데이트 에러: \(error)")
                } else {
                    print("평가 업데이트 성공")
                }
            }
        
        if type == .message { // 메시지를 보내는 경우
            // 받는 사람
            dbRef.collection(Collections.mail.name).document(receiveUser.id).setData(
                [
                    "userId": receiveUser.id,
                    "receiveMailInfo": FieldValue.arrayUnion([receiveMessages])
                ], merge: true) { error in
                    if let error = error {
                        print("평가 업데이트 에러: \(error)")
                    } else {
                        print("평가 업데이트 성공")
                    }
                }
            
            NotificationService.shared.sendNotification(userId: receiveUser.id, sendUserName: senderUser.nickName, notiType: .message)
            
        } else { // 매칭의 경우
            dbRef.collection(Collections.mail.name).document(receiveUser.id).setData(
                [
                    "userId": receiveUser.id,
                    "sendMailInfo": FieldValue.arrayUnion([sendMessages])
                ], merge: true) { error in
                    if let error = error {
                        print("평가 업데이트 에러: \(error)")
                    } else {
                        print("평가 업데이트 성공")
                    }
                }
        }
        
        guard let senderMbti = MBTIType(rawValue: senderUser.mbti) else { return }
        let receiverNoti = Noti(receiveId: receiveUser.id, sendId: senderUser.userId, name: senderUser.nickName, birth: senderUser.birth, imageUrl: senderUser.imageURL, notiType: .message, mbti: senderMbti, createDate: Date().timeIntervalSince1970)
        
        FirestoreService.shared.saveDocument(collectionId: .notifications, data: receiverNoti)
    }
    
    func getUser(userId: String, completion: @escaping () -> ()) {
        DispatchQueue.global().async {
            let query = self.dbRef.collection(Collections.users.name)
                .whereField("id", isEqualTo: userId)
            
            query.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print(error)
                } else {
                    for document in querySnapshot!.documents {
                        if let userdata = try? document.data(as: User.self) {
                            self.user = userdata
                            completion()
                        }
                    }
                }
            }
        }
    }
}
