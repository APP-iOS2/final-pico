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
        
        input.listLoad
            .withUnretained(self)
            .subscribe { viewModel, _ in
                viewModel.loadNextChattingPage()
            }
            .disposed(by: disposeBag)
        
        return Output(reloadChattingTableView: reloadChattingTableViewPublisher.asObservable())
    }
    
    func loadNextChattingPage() {
        dbRef.collection(Collections.chatDetail.name)
            .document(roomId)
            .addSnapshotListener { (documentSnapshot, error) in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                if let datas = try? document.data(as: ChatDetail.self).chatInfo {
                    let sorted = datas.sorted(by: {$0.sendedDate < $1.sendedDate})
                    self.chattingArray = sorted
                    
                    DispatchQueue.main.async {
                        self.reloadChattingTableViewPublisher.onNext(())
                    }
                }
            }
    }
}
// MARK: - saveChatting
extension ChattingDetailViewModel {
    func updateChattingData(roomId: String, receiveUserId: String, chatInfo: ChatDetail.ChatInfo) {
        FirestoreService.shared.saveDocument(collectionId: .chatDetail, documentId: roomId, fieldId: "chatInfo", data: chatInfo) { result in
            switch result {
            case .success(let data):
                print("updateChattingData saveDocument \(data)")
            case .failure(let err):
                print("err: updateChattingData saveDocument \(err)")
            }
        }
        
        // noti
        NotificationService.shared.sendNotification(userId: receiveUserId, sendUserName: user.nickName, notiType: .message, messageContent: chatInfo.message)
        guard let senderMbti = MBTIType(rawValue: user.mbti) else { return }
        let receiverNoti = Noti(receiveId: receiveUserId, sendId: user.userId, name: user.nickName, birth: user.birth, imageUrl: user.imageURL, notiType: .message, mbti: senderMbti, createDate: Date().timeIntervalSince1970)
        FirestoreService.shared.saveDocument(collectionId: .notifications, documentId: receiverNoti.id ?? UUID().uuidString, data: receiverNoti)
    }
    
    func updateRoomData(roomId: String, receiveUserId: String, chatInfo: ChatDetail.ChatInfo) {
        let senderRoomData = ChatRoom.RoomInfo(roomId: roomId, opponentId: receiveUserId, lastMessage: chatInfo.message, sendedDate: chatInfo.sendedDate)
        
        let receiverRoomData = ChatRoom.RoomInfo(roomId: roomId, opponentId: user.userId, lastMessage: chatInfo.message, sendedDate: chatInfo.sendedDate)
        
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            FirestoreService.shared.loadDocument(collectionId: .chatRoom, documentId: receiveUserId, dataType: ChatRoom.self) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let data):
                    guard let data else { return }
                    
                    let checkRoom = data.roomInfo.firstIndex(where: {$0.roomId == roomId})
                    var sameRoom: ChatRoom.RoomInfo? {
                        if checkRoom != nil {
                            return data.roomInfo[checkRoom ?? 0]
                        }
                        return nil
                    }
                    
                    if sameRoom != nil {
                        dbRef.collection(Collections.room.name).document(receiveUserId).updateData([
                            "room": FieldValue.arrayRemove([sameRoom.asDictionary()])
                        ])
                    }
                    dbRef.collection(Collections.room.name).document(receiveUserId).updateData([
                        "room": FieldValue.arrayUnion([receiverRoomData.asDictionary()])
                    ])
                    
                case .failure(let error):
                    print("받는 사람의 룸 불러오기 실패: \(error)")
                }
            }
            
            FirestoreService.shared.loadDocument(collectionId: .chatRoom, documentId: user.userId, dataType: ChatRoom.self) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    guard let data else { return }
                    
                    let checkRoom = data.roomInfo.firstIndex(where: {$0.roomId == roomId})
                    var sameRoom: ChatRoom.RoomInfo? {
                        if checkRoom != nil {
                            return data.roomInfo[checkRoom ?? 0]
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
                    
                case .failure(let error):
                    print("자신의 룸 불러오기 실패: \(error)")
                }
            }
        }
        
        guard let senderMbti = MBTIType(rawValue: user.mbti) else { return }
        let receiverNoti = Noti(receiveId: receiveUserId, sendId: user.userId, name: user.nickName, birth: user.birth, imageUrl: user.imageURL, notiType: .message, mbti: senderMbti, createDate: Date().timeIntervalSince1970)
        FirestoreService.shared.saveDocument(collectionId: .notifications, data: receiverNoti)
    }
    
    func saveChattingData(receiveUserId: String, message: String, sendedDate: Double = Date().timeIntervalSince1970) {
        let roomId = UUID().uuidString
        
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            saveRoom(roomId: roomId, receiveUserId: receiveUserId, message: message, sendedDate: sendedDate)
            saveChatting(roomId: roomId, receiveUserId: receiveUserId, message: message, sendedDate: sendedDate)
            
            /// noti 보내기
            guard let senderMbti = MBTIType(rawValue: self.user.mbti) else { return }
            let receiverNoti = Noti(receiveId: receiveUserId, sendId: self.user.userId, name: self.user.nickName, birth: self.user.birth, imageUrl: self.user.imageURL, notiType: .message, mbti: senderMbti, createDate: Date().timeIntervalSince1970)
            FirestoreService.shared.saveDocument(collectionId: .notifications, data: receiverNoti)
        }
    }
    
    private func saveRoom(roomId: String, receiveUserId: String, message: String, sendedDate: Double) {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            var roomInfo = ChatRoom.RoomInfo(roomId: roomId, opponentId: receiveUserId, lastMessage: message, sendedDate: sendedDate)
            
            FirestoreService.shared.saveDocument(collectionId: .chatRoom, documentId: user.userId, fieldId: "roomInfo", data: roomInfo) { result in
                switch result {
                case .success(let data):
                    print("saveRoom saveDocument sendUserId \(data)")
                case .failure(let err):
                    print(err)
                }
            }
            
            roomInfo = ChatRoom.RoomInfo(roomId: roomId, opponentId: user.userId, lastMessage: message, sendedDate: sendedDate)
            FirestoreService.shared.saveDocument(collectionId: .chatRoom, documentId: receiveUserId, fieldId: "roomInfo", data: roomInfo) { result in
                switch result {
                case .success(let data):
                    print("saveRoom saveDocument receiveUserId \(data)")
                case .failure(let err):
                    print(err)
                }
            }
        }
    }
    
    private func saveChatting(roomId: String, receiveUserId: String, message: String, sendedDate: Double) {
        let chatInfo = ChatDetail.ChatInfo(sendUserId: user.userId, message: message, sendedDate: sendedDate, isReading: false)
        
        FirestoreService.shared.saveDocument(collectionId: .chatDetail, documentId: roomId, fieldId: "chatInfo", data: chatInfo) { result in
            switch result {
            case .success(let data):
                print("saveRoom saveDocument \(data)")
            case .failure(let err):
                print(err)
            }
        }
    }
}
