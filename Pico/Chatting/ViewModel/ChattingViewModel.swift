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
    
    private var isChattingEmptyPublisher = PublishSubject<Bool>()
    private let reloadChattingTableViewPublisher = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    
    private let dbRef = Firestore.firestore()
    private let user = UserDefaultsManager.shared.getUserData()
    private var itemsPerPage: Int = Int(Screen.height * 1.5 / 60)
    var lastDocumentSnapshot: DocumentSnapshot?
    var startIndex = 0
    var roomId = UserDefaults.standard.string(forKey: UserDefaultsManager.Key.roomId.rawValue) ?? ""
    var opponentName = ""
    
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
                viewModel.refresh()
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
        
        let endIndex = startIndex + itemsPerPage
        
        DispatchQueue.global().async {
            ref.getDocument { [weak self] document, error in
                guard let self = self else { return }
                if let error = error {
                    print(error)
                    return
                }
                
                if let document = document, document.exists {
                    if let datas = try? document.data(as: Chatting.self).senderChatting?
                        .filter({ $0.messageType == .send })
                        .filter({ $0.roomId == self.roomId}) {
                        let sorted = datas.sorted {
                            return $0.sendedDate > $1.sendedDate
                        }
                        if startIndex > sorted.count - 1 {
                            return
                        }
                        let currentPageDatas: [Chatting.ChattingInfo] = Array(sorted[startIndex..<min(endIndex, sorted.count)])
                        print("send: \(currentPageDatas)")
                        sendChattingList += currentPageDatas
                        
                        if startIndex == 0 {
                            reloadChattingTableViewPublisher.onNext(())
                        }
                        startIndex += currentPageDatas.count
                    }
                } else {
                    print("보낸 문서를 찾을 수 없습니다.")
                }
                
                if let document = document, document.exists {
                    if let datas = try? document.data(as: Chatting.self).receiverChatting?
                        .filter({ $0.messageType == .receive})
                        .filter({ $0.roomId == self.roomId}) {
                        let sorted = datas.sorted {
                            return $0.sendedDate < $1.sendedDate
                        }
                        if startIndex > sorted.count - 1 {
                            return
                        }
                        let currentPageDatas: [Chatting.ChattingInfo] = Array(sorted[startIndex..<min(endIndex, sorted.count)])
                        receiveChattingList += currentPageDatas
                        print("receive: \(receiveChattingList)")
                        if startIndex == 0 {
                            reloadChattingTableViewPublisher.onNext(())
                        }
                        startIndex += currentPageDatas.count
                    }
                } else {
                    print("보낸 문서를 찾을 수 없습니다.")
                }
            }
        }
    }
    
    private func refresh() {
        let didSet = isChattingEmptyPublisher
        isChattingEmptyPublisher = PublishSubject<Bool>()
        receiveChattingList = []
        sendChattingList = []
        startIndex = 0
        isChattingEmptyPublisher = didSet
        loadNextChattingPage()
    }
}
// MARK: - saveChatting
extension ChattingViewModel {
    func updateRoomData(data: Chatting.ChattingInfo) {
        let senderRoomData = Room.RoomInfo(id: data.roomId, userId: user.userId, opponentId: data.receiveUserId, lastMessage: data.message, sendedDate: data.sendedDate)
        
        let receiverRoomData = Room.RoomInfo(id: data.roomId, userId: data.receiveUserId, opponentId: user.userId, lastMessage: data.message, sendedDate: data.sendedDate)
        
        let receiverData = Chatting.ChattingInfo(roomId: data.roomId, sendUserId: data.sendUserId, receiveUserId: data.receiveUserId, message: data.message, sendedDate: data.sendedDate, isReading: false, messageType: .receive)
        
        FirestoreService.shared.loadDocument(collectionId: .room, documentId: self.user.userId, dataType: Room.self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                guard let data else { return }
                var sameRoom = data.room?.filter({$0.id == senderRoomData.id})
                if sameRoom != nil {
                    self.dbRef.collection(Collections.room.name).document(user.userId).updateData([
                        "room": FieldValue.arrayRemove([sameRoom.asDictionary()])
                    ])
                    
                    self.dbRef.collection(Collections.room.name).document(senderRoomData.opponentId).updateData([
                        "room": FieldValue.arrayRemove([sameRoom.asDictionary()])
                    ])
                }
                self.dbRef.collection(Collections.room.name).document(user.userId).updateData([
                    "room": FieldValue.arrayUnion([senderRoomData.asDictionary()])
                ])
                
                self.dbRef.collection(Collections.room.name).document(senderRoomData.opponentId).updateData([
                    "room": FieldValue.arrayUnion([receiverRoomData.asDictionary()])
                ])
                // chatting
                self.dbRef.collection(Collections.chatting.name).document(user.userId).updateData([
                    "senderChatting": FieldValue.arrayUnion([data.asDictionary()])
                ])
                
                self.dbRef.collection(Collections.chatting.name).document(senderRoomData.opponentId).updateData([
                    "receiverChatting": FieldValue.arrayUnion([receiverData.asDictionary()])
                ])
            case .failure(let error):
                print("3")
                print("룸 불러오기 실패: \(error)")
            }
        }
    }
    
    func saveChattingData(receiveUserId: String, message: String) {
        
        let roomId = UUID().uuidString
        
        DispatchQueue.global().async {
            
            self.saveSender(roomId: roomId, receiveUserId: receiveUserId, message: message)
            self.saveReceiver(roomId: roomId, receiveUserId: receiveUserId, message: message)
            
            guard let senderMbti = MBTIType(rawValue: self.user.mbti) else { return }
            
            let receiverNoti = Noti(receiveId: receiveUserId, sendId: self.user.userId, name: self.user.nickName, birth: self.user.birth, imageUrl: self.user.imageURL, notiType: .message, mbti: senderMbti, createDate: Date().timeIntervalSince1970)
            
            FirestoreService.shared.saveDocument(collectionId: .notifications, data: receiverNoti)
        }
        print("매칭 데이터 업데이트 완료")
    }
    
    private func saveSender(roomId: String, receiveUserId: String, message: String) {
        
        let matchingReceiveMessages: [String: Any] = [
            "roomId": roomId,
            "sendUserId": receiveUserId,
            "receiveUserId": user.userId,
            "message": message,
            "sendedDate": Date().timeIntervalSince1970,
            "isReading": false,
            "messageType": "receive"
        ]
        
        let sendRoomMessages: [String: Any] = [
            "id": roomId,
            "userId": self.user.userId,
            "opponentId": receiveUserId,
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
            
            self.dbRef.collection(Collections.chatting.name).document(self.user.userId).setData(
                [
                    "userId": self.user.userId,
                    "receiverChatting": FieldValue.arrayUnion([matchingReceiveMessages])
                ], merge: true) { error in
                    if let error = error {
                        print("평가 업데이트 에러: \(error)")
                    }
                }
        }
    }
    
    private func saveReceiver(roomId: String, receiveUserId: String, message: String) {
        
        let receiveMessages: [String: Any] = [
            "id": UUID().uuidString,
            "roomId": roomId,
            "sendUserId": user.userId,
            "receiveUserId": receiveUserId,
            "message": message,
            "sendedDate": Date().timeIntervalSince1970,
            "isReading": false,
            "messageType": "receive"
        ]
        
        let receiveRoomMessages: [String: Any] = [
            "id": roomId,
            "userId": receiveUserId,
            "opponentId": user.userId,
            "lastMessage": message,
            "sendedDate": Date().timeIntervalSince1970
        ]
        
        DispatchQueue.global().async {
            
            self.dbRef.collection(Collections.room.name).document(receiveUserId).setData(
                [
                    "userId": receiveUserId,
                    "room": FieldValue.arrayUnion([receiveRoomMessages])
                ], merge: true) { error in
                    if let error = error {
                        print("보내기 업데이트 에러: \(error)")
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
}
