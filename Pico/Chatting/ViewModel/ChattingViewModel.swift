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

final class ChattingViewModel {
    
    private(set) var sendChattingList: [Chatting.ChattingInfo] = []
    private(set) var receiveChattingList: [Chatting.ChattingInfo] = []
    private(set) var chattingArray: [Chatting.ChattingInfo] = []
    
    private let reloadChattingTableViewPublisher = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    
    private let dbRef = Firestore.firestore()
    private let user = UserDefaultsManager.shared.getUserData()
    
    var isPaging: Bool = false
    var chattingIndex: Int = 0
    
    var roomId = UserDefaults.standard.string(forKey: UserDefaultsManager.Key.roomId.rawValue) ?? ""
    
    struct Input {
        let listLoad: Observable<Void>
        let refresh: Observable<Void>
    }
    
    struct Output {
        let reloadChattingTableView: Observable<Void>
    }
    
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
        let ref = dbRef.collection(Collections.chatting.name).document(user.userId)
        
        DispatchQueue.global().async {
            ref.getDocument { [weak self] document, error in
                guard let self = self else { return }
                if let error = error {
                    print(error)
                    return
                }
                
                if let document = document, document.exists {
                    if let datas = try? document.data(as: Chatting.self).senderChatting?
                        .filter({ $0.roomId == self.roomId }) {
                        
                        let sorted = datas.sorted {
                            return $0.sendedDate < $1.sendedDate
                        }
                        sendChattingList += sorted
                        print("send --------- \(sendChattingList.count)")
                    }
                    
                    if let datas = try? document.data(as: Chatting.self).receiverChatting?
                        .filter({ $0.roomId == self.roomId}) {
                        let sorted = datas.sorted {
                            return $0.sendedDate < $1.sendedDate
                        }
                        receiveChattingList += sorted
                        print("receive --------- \(receiveChattingList.count)")
                    }
                } else {
                    print("받은 문서를 찾을 수 없습니다.")
                }
                
                chattingArray = sendChattingList + receiveChattingList
                chattingArray.sort(by: {$0.sendedDate < $1.sendedDate})
            }
        }
    }
    
    private func refreshChatting() {
        sendChattingList = []
        receiveChattingList = []
        loadNextChattingPage()
    }
}
// MARK: - saveChatting
extension ChattingViewModel {
    func updateChattingData(chattingData: Chatting.ChattingInfo) {
        
        let receiverData = Chatting.ChattingInfo(roomId: chattingData.roomId, sendUserId: chattingData.sendUserId, receiveUserId: chattingData.receiveUserId, message: chattingData.message, sendedDate: chattingData.sendedDate, isReading: false, messageType: .receive)
        
        // chatting
        self.dbRef.collection(Collections.chatting.name).document(user.userId).updateData([
            "senderChatting": FieldValue.arrayUnion([chattingData.asDictionary()])
        ])
        
        self.dbRef.collection(Collections.chatting.name).document(chattingData.receiveUserId).updateData([
            "receiverChatting": FieldValue.arrayUnion([receiverData.asDictionary()])
        ])
        
        NotificationService.shared.sendNotification(userId: chattingData.receiveUserId, sendUserName: user.nickName, notiType: .message, messageContent: chattingData.message)
        
        guard let senderMbti = MBTIType(rawValue: user.mbti) else { return }
        let receiverNoti = Noti(receiveId: chattingData.receiveUserId, sendId: user.userId, name: user.nickName, birth: user.birth, imageUrl: user.imageURL, notiType: .message, mbti: senderMbti, createDate: Date().timeIntervalSince1970)
        
        FirestoreService.shared.saveDocument(collectionId: .notifications, documentId: receiverNoti.id ?? UUID().uuidString, data: receiverNoti)
    }
    
    func updateRoomData(chattingData: Chatting.ChattingInfo) {
        let senderRoomData = Room.RoomInfo(id: chattingData.roomId, userId: user.userId, opponentId: chattingData.receiveUserId, lastMessage: chattingData.message, sendedDate: chattingData.sendedDate)
        
        let receiverRoomData = Room.RoomInfo(id: chattingData.roomId, userId: chattingData.receiveUserId, opponentId: user.userId, lastMessage: chattingData.message, sendedDate: chattingData.sendedDate)
        
        DispatchQueue.global().async {
            
            FirestoreService.shared.loadDocument(collectionId: .room, documentId: chattingData.receiveUserId, dataType: Room.self) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    guard let data else { return }
                    if let room = data.room {
                        let checkRoom = room.firstIndex(where: {$0.id == chattingData.roomId})
                        var sameRoom: Room.RoomInfo? {
                            if checkRoom != nil {
                                return room[checkRoom ?? 0]
                            }
                            return nil
                        }
                        
                        if sameRoom != nil {
                            dbRef.collection(Collections.room.name).document(receiverRoomData.userId).updateData([
                                "room": FieldValue.arrayRemove([sameRoom.asDictionary()])
                            ])
                        }
                        dbRef.collection(Collections.room.name).document(receiverRoomData.userId).updateData([
                            "room": FieldValue.arrayUnion([receiverRoomData.asDictionary()])
                        ])
                    }
                case .failure(let error):
                    print("받는 사람의 룸 불러오기 실패: \(error)")
                }
            }
            
            FirestoreService.shared.loadDocument(collectionId: .room, documentId: self.user.userId, dataType: Room.self) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    guard let data else { return }
                    if let room = data.room {
                        let checkRoom = room.firstIndex(where: {$0.id == chattingData.roomId})
                        var sameRoom: Room.RoomInfo? {
                            if checkRoom != nil {
                                return room[checkRoom ?? 0]
                            }
                            return nil
                        }
                        if sameRoom != nil {
                            dbRef.collection(Collections.room.name).document(user.userId).updateData([
                                "room": FieldValue.arrayRemove([sameRoom.asDictionary()])
                            ])
                        }
                        dbRef.collection(Collections.room.name).document(user.userId).updateData([
                            "room": FieldValue.arrayUnion([senderRoomData.asDictionary()])
                        ])
                    }
                case .failure(let error):
                    print("자신의 룸 불러오기 실패: \(error)")
                }
            }
        }
        
        guard let senderMbti = MBTIType(rawValue: self.user.mbti) else { return }
        
        let receiverNoti = Noti(receiveId: chattingData.receiveUserId, sendId: self.user.userId, name: self.user.nickName, birth: self.user.birth, imageUrl: self.user.imageURL, notiType: .message, mbti: senderMbti, createDate: Date().timeIntervalSince1970)
        
        FirestoreService.shared.saveDocument(collectionId: .notifications, data: receiverNoti)
        
    }
    
    func saveChattingData(receiveUserId: String, message: String) {
        
        let roomId = UUID().uuidString
        
        DispatchQueue.global().async {
            
            self.saveChatting(roomId: roomId, receiveUserId: receiveUserId, message: message)
            self.saveRoom(roomId: roomId, receiveUserId: receiveUserId, message: message)
            
            guard let senderMbti = MBTIType(rawValue: self.user.mbti) else { return }
            
            let receiverNoti = Noti(receiveId: receiveUserId, sendId: self.user.userId, name: self.user.nickName, birth: self.user.birth, imageUrl: self.user.imageURL, notiType: .message, mbti: senderMbti, createDate: Date().timeIntervalSince1970)
            
            FirestoreService.shared.saveDocument(collectionId: .notifications, data: receiverNoti)
        }
        print("매칭 데이터 업데이트 완료")
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
