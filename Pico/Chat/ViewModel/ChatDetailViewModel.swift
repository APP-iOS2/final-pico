//
//  ChatDetailViewModel.swift
//  Pico
//
//  Created by 양성혜 on 2023/12/16.
//

import UIKit
import RxSwift
import RxRelay
import FirebaseFirestore

final class ChatDetailViewModel {
    struct Input {
        let listLoad: Observable<Void>
    }
    
    struct Output {
        let reloadChatDetailTableView: Observable<Void>
    }
    
    private(set) var chatInfoArray: [ChatDetail.ChatInfo] = []
    
    private let reloadChatDetailTableViewPublisher = PublishSubject<Void>()
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
                viewModel.loadChatDetail()
            }
            .disposed(by: disposeBag)
        
        return Output(reloadChatDetailTableView: reloadChatDetailTableViewPublisher.asObservable())
    }
    
    func loadChatDetail() {
        dbRef.collection(Collections.chatDetail.name)
            .document(roomId)
            .addSnapshotListener { (documentSnapshot, error) in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                if let datas = try? document.data(as: ChatDetail.self).chatInfo {
                    let sorted = datas.sorted(by: {$0.sendedDate < $1.sendedDate})
                    self.chatInfoArray = sorted
                    
                    DispatchQueue.main.async {
                        self.reloadChatDetailTableViewPublisher.onNext(())
                    }
                }
            }
    }
}
// MARK: - saveChatting
extension ChatDetailViewModel {
    func updateChatInfo(roomId: String, receiveUserId: String, chatInfo: ChatDetail.ChatInfo) {
        FirestoreService.shared.saveDocument(collectionId: .chatDetail, documentId: roomId, fieldId: "chatInfo", data: chatInfo) { result in
            switch result {
            case .success(let data):
                print("updateChatInfo saveDocument \(data)")
            case .failure(let err):
                print("err: updateChatInfo saveDocument \(err)")
            }
        }
        
        // noti
        NotificationService.shared.sendNotification(userId: receiveUserId, sendUserName: user.nickName, notiType: .message, messageContent: chatInfo.message)
    }
    
    func updateRoomInfo(roomId: String, receiveUserId: String, chatInfo: ChatDetail.ChatInfo) {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            FirestoreService.shared.loadDocument(collectionId: .chatRoom, documentId: receiveUserId, dataType: ChatRoom.self) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let data):
                    guard let data else { return }
                    
                    var filteredRooms = data.roomInfo.filter({ $0.roomId != roomId })
                    filteredRooms.append(ChatRoom.RoomInfo(roomId: roomId, opponentId: user.userId, lastMessage: chatInfo.message, sendedDate: chatInfo.sendedDate))
                    let rooms = ChatRoom(roomInfo: filteredRooms)
                    
                    FirestoreService.shared.saveDocument(collectionId: .chatRoom, documentId: receiveUserId, data: rooms)
                    
                case .failure(let error):
                    print("받는 사람의 룸 불러오기 실패: \(error)")
                }
            }
            
            FirestoreService.shared.loadDocument(collectionId: .chatRoom, documentId: user.userId, dataType: ChatRoom.self) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let data):
                    guard let data else { return }
                    
                    var filteredRooms = data.roomInfo.filter({ $0.roomId != roomId })
                    filteredRooms.append(ChatRoom.RoomInfo(roomId: roomId, opponentId: receiveUserId, lastMessage: chatInfo.message, sendedDate: chatInfo.sendedDate))
                    let rooms = ChatRoom(roomInfo: filteredRooms)
                    
                    FirestoreService.shared.saveDocument(collectionId: .chatRoom, documentId: user.userId, data: rooms)
                    
                case .failure(let error):
                    print("자신의 룸 불러오기 실패: \(error)")
                }
            }
        }
    }
    
    func saveMatchingChat(receiveUserId: String, message: String, sendedDate: Double = Date().timeIntervalSince1970) {
        let roomId = UUID().uuidString
        
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            saveRoomInfo(roomId: roomId, receiveUserId: receiveUserId, message: message, sendedDate: sendedDate)
            saveChatInfo(roomId: roomId, receiveUserId: receiveUserId, message: message, sendedDate: sendedDate)
        }
    }
    
    private func saveRoomInfo(roomId: String, receiveUserId: String, message: String, sendedDate: Double) {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            var roomInfo = ChatRoom.RoomInfo(roomId: roomId, opponentId: receiveUserId, lastMessage: message, sendedDate: sendedDate)
            
            FirestoreService.shared.saveDocument(collectionId: .chatRoom, documentId: user.userId, fieldId: "roomInfo", data: roomInfo) { result in
                switch result {
                case .success(let data):
                    print("saveRoomInfo saveDocument sendUserId \(data)")
                case .failure(let err):
                    print(err)
                }
            }
            
            roomInfo = ChatRoom.RoomInfo(roomId: roomId, opponentId: user.userId, lastMessage: message, sendedDate: sendedDate)
            FirestoreService.shared.saveDocument(collectionId: .chatRoom, documentId: receiveUserId, fieldId: "roomInfo", data: roomInfo) { result in
                switch result {
                case .success(let data):
                    print("saveRoomInfo saveDocument receiveUserId \(data)")
                case .failure(let err):
                    print(err)
                }
            }
        }
    }
    
    private func saveChatInfo(roomId: String, receiveUserId: String, message: String, sendedDate: Double) {
        let chatInfo = ChatDetail.ChatInfo(sendUserId: user.userId, message: message, sendedDate: sendedDate, isReading: false)
        
        FirestoreService.shared.saveDocument(collectionId: .chatDetail, documentId: roomId, fieldId: "chatInfo", data: chatInfo) { result in
            switch result {
            case .success(let data):
                print("saveChatInfo saveDocument \(data)")
            case .failure(let err):
                print(err)
            }
        }
    }
}
