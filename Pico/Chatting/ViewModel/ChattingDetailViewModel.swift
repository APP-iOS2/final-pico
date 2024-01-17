//
//  ChattingViewModel.swift
//  Pico
//
//  Created by 양성혜 on 2023/12/16.
//

import UIKit
import RxSwift
import RxRelay
import FirebaseFirestore

final class ChattingDetailViewModel {
    struct Input {
        let listLoad: Observable<Void>
        let refresh: Observable<Void>
    }
    
    struct Output {
        let reloadChattingTableView: Observable<Void>
    }
    
    private(set) var chattingArray: [ChatDetail.ChatInfo] = []
    
    private let reloadChattingTableViewPublisher = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    
    private let dbRef = Firestore.firestore()
    private let user = UserDefaultsManager.shared.getUserData()
    
    var isPaging: Bool = false
    var chattingIndex: Int = 0
    
    var roomId: String = ""
    
    func transform(input: Input) -> Output {
        input.refresh
            .withUnretained(self)
            .subscribe { viewModel, _ in
                viewModel.refreshChatting()
            }
            .disposed(by: disposeBag)
        
        input.listLoad
            .withUnretained(self)
            .subscribe { viewModel, _ in
                viewModel.loadNextChattingPage()
            }
            .disposed(by: disposeBag)
        
        return Output(reloadChattingTableView: reloadChattingTableViewPublisher.asObservable())
    }
    
    func loadNextChattingPage() {
        let ref = dbRef.collection(Collections.chatDetail.name).document(roomId)
        
        DispatchQueue.global().async {
            ref.addSnapshotListener { (documentSnapshot, error) in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                if let datas = try? document.data(as: ChatDetail.self).chatInfo {
                    let sorted = datas.sorted(by: {$0.sendedDate < $1.sendedDate})
                    self.chattingArray = sorted
                }
                
//                if let datas = try? document.data(as: Chatting.self).senderChatting?
//                    .filter({ $0.roomId == self.roomId }) {
//                    self.chattingArray += datas
//                    }
//                
//                if let datas = try? document.data(as: Chatting.self).receiverChatting?
//                    .filter({ $0.roomId == self.roomId}) {
//                    self.chattingArray += datas
//                }
//                
//                self.chattingArray.sort(by: {$0.sendedDate < $1.sendedDate})
            }
        }
    }
    
    private func refreshChatting() {
        chattingArray = []
        loadNextChattingPage()
    }
}
// MARK: - saveChatting
extension ChattingDetailViewModel {
    func updateChattingData(roomId: String, receiveUserId: String, chatInfo: ChatDetail.ChatInfo) {
        
        FirestoreService.shared.saveDocument(collectionId: .chatDetail, documentId: roomId, fieldId: "chatInfo", data: chatInfo) { result in
            switch result {
            case .success( _):
                print("updateChattingData saveDocument")
            case .failure(let err):
                print("err: updateChattingData saveDocument \(err)")
            }
        }
     
//        let receiverData = Chatting.ChattingInfo(roomId: chattingData.roomId, sendUserId: chattingData.sendUserId, receiveUserId: chattingData.receiveUserId, message: chattingData.message, sendedDate: chattingData.sendedDate, isReading: false, messageType: .receive)
//        
//        // chatting
//        self.dbRef.collection(Collections.chatting.name).document(user.userId).updateData([
//            "senderChatting": FieldValue.arrayUnion([chattingData.asDictionary()])
//        ])
//        
//        self.dbRef.collection(Collections.chatting.name).document(chattingData.receiveUserId).updateData([
//            "receiverChatting": FieldValue.arrayUnion([receiverData.asDictionary()])
//        ])
        
        // noti
        NotificationService.shared.sendNotification(userId: receiveUserId, sendUserName: user.nickName, notiType: .message, messageContent: chatInfo.message)
        guard let senderMbti = MBTIType(rawValue: user.mbti) else { return }
        let receiverNoti = Noti(receiveId: receiveUserId, sendId: user.userId, name: user.nickName, birth: user.birth, imageUrl: user.imageURL, notiType: .message, mbti: senderMbti, createDate: Date().timeIntervalSince1970)
        FirestoreService.shared.saveDocument(collectionId: .notifications, documentId: receiverNoti.id ?? UUID().uuidString, data: receiverNoti)
    }
    
    func updateRoomData(roomId: String, receiveUserId: String) {
        DispatchQueue.global().async {
            
        }
        
        guard let senderMbti = MBTIType(rawValue: user.mbti) else { return }
        let receiverNoti = Noti(receiveId: receiveUserId, sendId: user.userId, name: user.nickName, birth: user.birth, imageUrl: user.imageURL, notiType: .message, mbti: senderMbti, createDate: Date().timeIntervalSince1970)
        FirestoreService.shared.saveDocument(collectionId: .notifications, data: receiverNoti)
    }
    
    func saveChattingData(receiveUserId: String, message: String) {
        let roomId = UUID().uuidString
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            saveRoom2(roomId: roomId, receiveUserId: receiveUserId, message: message)
            saveChatting2(roomId: roomId, receiveUserId: receiveUserId, message: message)
            
            /// noti 보내기
            guard let senderMbti = MBTIType(rawValue: self.user.mbti) else { return }
            let receiverNoti = Noti(receiveId: receiveUserId, sendId: self.user.userId, name: self.user.nickName, birth: self.user.birth, imageUrl: self.user.imageURL, notiType: .message, mbti: senderMbti, createDate: Date().timeIntervalSince1970)
            FirestoreService.shared.saveDocument(collectionId: .notifications, data: receiverNoti)
        }
        print("매칭 데이터 업데이트 완료")
    }
    
    private func saveRoom2(roomId: String, receiveUserId: String, message: String) {
        let sendedDate = Date().timeIntervalSince1970
        
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            var roomInfo = ChatRoom.RoomInfo(roomId: roomId, opponentId: receiveUserId, lastMessage: message, sendedDate: sendedDate)
            FirestoreService.shared.saveDocument(collectionId: .chatRoom, documentId: user.userId, fieldId: "roomInfo", data: roomInfo) { result in
                switch result {
                case .success(let data):
                    print("saveRoom2 saveDocument sendUserId \(data)")
                case .failure(let err):
                    print(err)
                }
            }
            
            roomInfo = ChatRoom.RoomInfo(roomId: roomId, opponentId: user.userId, lastMessage: message, sendedDate: sendedDate)
            FirestoreService.shared.saveDocument(collectionId: .chatRoom, documentId: receiveUserId, fieldId: "roomInfo", data: roomInfo) { result in
                switch result {
                case .success(let data):
                    print("saveRoom2 saveDocument receiveUserId \(data)")
                case .failure(let err):
                    print(err)
                }
            }
        }
    }
    
    private func saveChatting2(roomId: String, receiveUserId: String, message: String) {
        let sendedDate = Date().timeIntervalSince1970
        let chatInfo = ChatDetail.ChatInfo(sendUserId: user.userId, message: message, sendedDate: sendedDate, isReading: false)
        
        FirestoreService.shared.saveDocument(collectionId: .chatDetail, documentId: roomId, fieldId: "chatInfo", data: chatInfo) { result in
            switch result {
            case .success(let data):
                print("saveRoom2 saveDocument \(data)")
            case .failure(let err):
                print(err)
            }
        }
    }
    
    private func saveChatting(roomId: String, receiveUserId: String, message: String) {
        
        let matchingReceiveMessages: [String: Any] = [
            "roomId": roomId,
            "sendUserId": receiveUserId,
            "receiveUserId": user.userId,
            "message": message,
            "sendedDate": Date().timeIntervalSince1970,
            "isReading": false,
            "messageType": "receive"
        ]
        
        let receiveMessages: [String: Any] = [
            "roomId": roomId,
            "sendUserId": user.userId,
            "receiveUserId": receiveUserId,
            "message": message,
            "sendedDate": Date().timeIntervalSince1970,
            "isReading": false,
            "messageType": "receive"
        ]
        
        DispatchQueue.global().async {
            
            self.dbRef.collection(Collections.chatting.name).document(self.user.userId).setData(
                [
                    "userId": self.user.userId,
                    "receiverChatting": FieldValue.arrayUnion([matchingReceiveMessages])
                ], merge: true) { error in
                    if let error = error {
                        print("평가 업데이트 에러: \(error)")
                    }
                }
            
            // 받는 사람
            self.dbRef.collection(Collections.chatting.name).document(receiveUserId).setData(
                [
                    "userId": receiveUserId,
                    "receiverChatting": FieldValue.arrayUnion([receiveMessages])
                ], merge: true) { error in
                    if let error = error {
                        print("받은사람 보내기 업데이트 에러: \(error)")
                    }
                }
        }
    }
    
    private func saveRoom(roomId: String, receiveUserId: String, message: String) {
        
        let sendRoomMessages: [String: Any] = [
            "id": roomId,
            "userId": self.user.userId,
            "opponentId": receiveUserId,
            "lastMessage": message,
            "sendedDate": Date().timeIntervalSince1970
        ]
        
        let receiveRoomMessages: [String: Any] = [
            "id": roomId,
            "userId": receiveUserId,
            "opponentId": user.userId,
            "lastMessage": message,
            "sendedDate": Date().timeIntervalSince1970
        ]
        
        DispatchQueue.global().async {
            self.dbRef.collection(Collections.room.name).document(self.user.userId).setData(
                [
                    "userId": self.user.userId,
                    "room": FieldValue.arrayUnion([sendRoomMessages])
                ], merge: true) { error in
                    if let error = error {
                        print("룸 데이터 업데이트 에러: \(error)")
                    }
                }
            
            self.dbRef.collection(Collections.room.name).document(receiveUserId).setData(
                [
                    "userId": receiveUserId,
                    "room": FieldValue.arrayUnion([receiveRoomMessages])
                ], merge: true) { error in
                    if let error = error {
                        print("보내기 업데이트 에러: \(error)")
                    }
                }
        }
    }
}
