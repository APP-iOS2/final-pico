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
    var doubleCheck: Bool = false
    
    func transform(input: Input) -> Output {
        input.listLoad
            .withUnretained(self)
            .subscribe { viewModel, _ in
                viewModel.loadChatDetail()
            }
            .disposed(by: disposeBag)
        
        return Output(
            reloadChatDetailTableView: reloadChatDetailTableViewPublisher.asObservable())
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
    
    func updateChat(roomId: String, receiveUserId: String, chatInfo: ChatDetail.ChatInfo) {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            FirestoreService.shared.loadDocument(collectionId: .users, documentId: receiveUserId, dataType: User.self) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let data):
                    guard let data else { return }
                    
                    updateChatInfo(roomId: roomId, receiveUserId: receiveUserId, chatInfo: chatInfo)
                    updateRoomInfo(roomId: roomId, receiveUser: data, chatInfo: chatInfo)
                    
                case .failure(let error):
                    print("상대 유저 불러오기 실패: \(error)")
                }
            }
        }
    }
    
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
    
    func updateRoomInfo(roomId: String, receiveUser: User, chatInfo: ChatDetail.ChatInfo) {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            FirestoreService.shared.loadDocument(collectionId: .chatRoom, documentId: receiveUser.id, dataType: ChatRoom.self) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let data):
                    guard let data else { return }
                    
                    var filteredRooms = data.roomInfo.filter({ $0.roomId != roomId })
                    guard let senderMbti = MBTIType(rawValue: user.mbti) else { return }
                    filteredRooms.append(ChatRoom.RoomInfo(roomId: roomId, opponentId: user.userId, opponentNickName: user.nickName, opponentMbti: senderMbti, opponentImageURL: user.imageURL, lastMessage: chatInfo.message, sendedDate: chatInfo.sendedDate))
                    let rooms = ChatRoom(roomInfo: filteredRooms)
                    
                    FirestoreService.shared.saveDocument(collectionId: .chatRoom, documentId: receiveUser.id, data: rooms)
                    
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
                    filteredRooms.append(ChatRoom.RoomInfo(roomId: roomId, opponentId: receiveUser.id, opponentNickName: receiveUser.nickName, opponentMbti: receiveUser.mbti, opponentImageURL: receiveUser.imageURLs[0], lastMessage: chatInfo.message, sendedDate: chatInfo.sendedDate))
                    let rooms = ChatRoom(roomInfo: filteredRooms)
                    
                    FirestoreService.shared.saveDocument(collectionId: .chatRoom, documentId: user.userId, data: rooms)
                    
                case .failure(let error):
                    print("자신의 룸 불러오기 실패: \(error)")
                }
            }
        }
    }
    
    func saveMatchingChat(receiveUserId: String, message: String, sendedDate: Double = Date().timeIntervalSince1970) {
        print("세이브매칭챗")
        let newRoomId = UUID().uuidString
        
        saveRoomInfo(roomId: newRoomId, receiveUserId: receiveUserId, message: message, sendedDate: sendedDate)
        saveChatInfo(roomId: newRoomId, receiveUserId: receiveUserId, message: message, sendedDate: sendedDate)
    }
    
    private func saveRoomInfo(roomId: String, receiveUserId: String, message: String, sendedDate: Double) {
        dbRef.collection(Collections.users.name).document(receiveUserId).getDocument { (snapshot, error) in
            if let error = error {
                print("saveMatchingChat: \(error.localizedDescription)")
                return
            }
            
            if let snapshot = snapshot, snapshot.exists {
                do {
                    let receiveUser = try snapshot.data(as: User.self)
                    
                        var roomInfo = ChatRoom.RoomInfo(roomId: roomId, opponentId: receiveUser.id, opponentNickName: receiveUser.nickName, opponentMbti: receiveUser.mbti, opponentImageURL: receiveUser.imageURLs[0], lastMessage: message, sendedDate: sendedDate)

                    FirestoreService.shared.saveDocument(collectionId: .chatRoom, documentId: self.user.userId, fieldId: "roomInfo", data: roomInfo) { result in
                            switch result {
                            case .success(let data):
                                print("saveRoomInfo saveDocument sendUserId \(data)")
                            case .failure(let err):
                                print(err)
                            }
                        }

                    guard let senderMbti = MBTIType(rawValue: self.user.mbti) else { return }
                    roomInfo = ChatRoom.RoomInfo(roomId: roomId, opponentId: self.user.userId, opponentNickName: self.user.nickName, opponentMbti: senderMbti, opponentImageURL: self.user.imageURL, lastMessage: message, sendedDate: sendedDate)
                        FirestoreService.shared.saveDocument(collectionId: .chatRoom, documentId: receiveUser.id, fieldId: "roomInfo", data: roomInfo) { result in
                            switch result {
                            case .success(let data):
                                print("saveRoomInfo saveDocument receiveUserId \(data)")
                            case .failure(let err):
                                print(err)
                            }
                        }
                } catch {
                    print("saveMatchingChat catch: \(error.localizedDescription)")
                }
            } else {
                print("saveMatchingChat snapshot 존재하지 않음")
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
