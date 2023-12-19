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
    
    private(set) var roomList: [Room.RoomInfo] = [] {
        didSet {
            if roomList.isEmpty {
                isChattingEmptyPublisher.onNext(true)
            } else {
                isChattingEmptyPublisher.onNext(false)
            }
        }
    }
    
    private(set) var chattingList: [Chatting.ChattingInfo] = [] {
        didSet {
            if chattingList.isEmpty {
                isChattingEmptyPublisher.onNext(true)
            } else {
                isChattingEmptyPublisher.onNext(false)
            }
        }
    }
    
    private var isChattingEmptyPublisher = PublishSubject<Bool>()
    private let reloadChattingTableViewPublisher = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    
    private let dbRef = Firestore.firestore()
                
    var lastDocumentSnapshot: DocumentSnapshot?
    private var itemsPerPage: Int = Int(Screen.height * 1.5 / 60)
    var startIndex = 0
    
    struct Input {
        let listLoad: Observable<Void>
        let refresh: Observable<Void>
        let isChattingEmptyChecked: Observable<Void>
    }
    
    struct Output {
        let chattingIsEmpty: Observable<Bool>
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
                //viewModel.loadNextChattingPage()
                viewModel.loadNextRoomPage()
            }
            .disposed(by: disposeBag)
        
        let didChattingeset = isChattingEmptyPublisher.asObservable()
            .map { result in
                return result
            }
        let chattingCheck = input.isChattingEmptyChecked
            .withUnretained(self)
            .map { viewModel, _ -> Bool in
                if viewModel.chattingList.isEmpty {
                    return true
                } else {
                    return false
                }
            }
        let isChattingEmpty = Observable.of(didChattingeset, chattingCheck).merge()
            .flatMapLatest { bool -> Observable<Bool> in
                return Observable.create { emitter in
                    emitter.onNext(bool)
                    return Disposables.create()
                }
            }
        
        return Output(chattingIsEmpty: isChattingEmpty, reloadChattingTableView: reloadChattingTableViewPublisher.asObservable())
    }
    
    func loadNextRoomPage() {
        
        var query = Firestore.firestore().collection(Collections.chatting.name)
            .whereField("userId", isEqualTo: UserDefaultsManager.shared.getUserData().userId)
            .limit(to: itemsPerPage)
        
        if let lastSnapshot = lastDocumentSnapshot {
            query = query.start(afterDocument: lastSnapshot) as! CollectionReference
        }
        
        DispatchQueue.global().async {
            query.getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print(error)
                    return
                }
                guard let documents = snapshot?.documents else { return }
                
                if documents.isEmpty {
                    return
                }
                
                lastDocumentSnapshot = documents.last
                
                for document in documents {
                    print(document.data())
                     if let data = try? document.data(as: Room.RoomInfo.self) {
                        roomList.append(data)
                         print("roomList----------- \(roomList)")
                    }
                    
                }
                reloadChattingTableViewPublisher.onNext(())
            }
        }
    }
    
    func loadNextChattingPage() {
        var query = dbRef.collection("room")
        // 상대편과의 마지막 대화를 가져오도록 필터링 해야 함
        // 굳이 다 받아와야해? 다 따로 받아오면 되잖아? 받아와서 넣어
        
            .whereFilter(Filter.orFilter([
                            Filter.whereField("sendUserId", isEqualTo: UserDefaultsManager.shared.getUserData().userId),
                            Filter.whereField("receiveUserId", isEqualTo: UserDefaultsManager.shared.getUserData().userId)
                        ]))
            .limit(to: itemsPerPage)
        
        if let lastSnapshot = lastDocumentSnapshot {
            query = query.start(afterDocument: lastSnapshot)
        }
        
        DispatchQueue.global().async {
            query.getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print(error)
                    return
                }
                guard let documents = snapshot?.documents else { return }
                
                if documents.isEmpty {
                    return
                }
                
                lastDocumentSnapshot = documents.last
                
                for document in documents {
                    print(document)
                    if let data = try? document.data(as: Chatting.ChattingInfo.self) {
                        chattingList.append(data)
                    }
                }
                reloadChattingTableViewPublisher.onNext(())
            }
        }
    }
    
    private func refresh() {
        let didSet = isChattingEmptyPublisher
        isChattingEmptyPublisher = PublishSubject<Bool>()
        chattingList = []
        startIndex = 0
        isChattingEmptyPublisher = didSet
        //loadNextChattingPage()
        loadNextRoomPage()
    }
    
    func updateNewData(roomData: Room.RoomInfo, chatData: Chatting.ChattingInfo) {
        let updateRoomData = roomData
        let updateChatData = chatData
        
        let ref = dbRef.collection(Collections.chatting.name).document(UserDefaultsManager.shared.getUserData().userId)
        
        DispatchQueue.global().async {
            
            ref.updateData([
                "room": FieldValue.arrayRemove([roomData.asDictionary()])
            ])
            
            ref.updateData([
                "room": FieldValue.arrayUnion([updateRoomData.asDictionary()])
            ])
            
            ref.collection("room").document(chatData.roomId).updateData([
                "userChatting": FieldValue.arrayRemove([chatData.asDictionary()])
            ])
            ref.collection("room").document(chatData.roomId).updateData([
                "userChatting": FieldValue.arrayUnion([updateChatData.asDictionary()])
            ])
        }
    }
    
    func saveChattingData(receiveUser: User, message: String, type: ChattingSendType) {
        
        let senderUser = UserDefaultsManager.shared.getUserData()
        
        let roomId = UUID().uuidString
        
        let senderDBRef = dbRef.collection(Collections.chatting.name).document(UserDefaultsManager.shared.getUserData().userId)
        
        let receiveDBRef = dbRef.collection(Collections.chatting.name).document(receiveUser.id)
        
        let sendMessages: [String: Any] = [
            "id": UUID().uuidString,
            "roomId": roomId,
            "sendUserId": senderUser.userId,
            "receiveUserId": receiveUser.id,
            "message": message,
            "sendedDate": Date().timeIntervalSince1970,
            "isReading": true
        ]
        
        let receiveMessages: [String: Any] = [
            "id": UUID().uuidString,
            "roomId": roomId,
            "sendUserId": senderUser.userId,
            "receiveUserId": receiveUser.id,
            "message": message,
            "sendedDate": Date().timeIntervalSince1970,
            "isReading": false
        ]
        
        let matchingReceiveMessages: [String: Any] = [
            "id": UUID().uuidString,
            "roomId": roomId,
            "sendUserId": receiveUser.id,
            "receiveUserId": senderUser.userId,
            "message": message,
            "sendedDate": Date().timeIntervalSince1970,
            "mailType": "receive",
            "isReading": false
        ]
        
        let roomMessages: [String: Any] = [
            "roomId": roomId,
            "opponentId": receiveUser.id,
            "lastMessage": message,
            "sendedDate": Date().timeIntervalSince1970
        ]
        
        // room 업데이트
        self.dbRef.collection(Collections.chatting.name).document(UserDefaultsManager.shared.getUserData().userId).setData(
            [
                "userId": UserDefaultsManager.shared.getUserData().userId,
                "room": FieldValue.arrayUnion([roomMessages])
            ], merge: true) { error in
                if let error = error {
                    print("평가 업데이트 에러: \(error)")
                }
            }
        
        // 받는 사람
        receiveDBRef.collection("room").document(roomId).setData(
            [
                "userId": receiveUser.id,
                "userChatting": FieldValue.arrayUnion([receiveMessages])
            ], merge: true) { error in
                if let error = error {
                    print("평가 업데이트 에러: \(error)")
                }
            }
        
        if type == .chatting { // 메시지를 보내는 경우
            // 보내는 사람
            dbRef.collection("room").document(roomId).setData(
                [
                    "userId": senderUser.userId,
                    "userChatting": FieldValue.arrayUnion([sendMessages])
                ], merge: true) { error in
                    if let error = error {
                        print("평가 업데이트 에러: \(error)")
                    }
                }
            
            NotificationService.shared.sendNotification(userId: receiveUser.id, sendUserName: senderUser.nickName, notiType: .message, messageContent: message)
            
        } else { // 매칭의 경우
            dbRef.collection("room").document(roomId).setData(
                [
                    "userId": senderUser.userId,
                    "userChatting": FieldValue.arrayUnion([matchingReceiveMessages])
                ], merge: true) { error in
                    if let error = error {
                        print("평가 업데이트 에러: \(error)")
                    }
                }
        }
        
        guard let senderMbti = MBTIType(rawValue: senderUser.mbti) else { return }
        
        let receiverNoti = Noti(receiveId: receiveUser.id, sendId: senderUser.userId, name: senderUser.nickName, birth: senderUser.birth, imageUrl: senderUser.imageURL, notiType: .message, mbti: senderMbti, createDate: Date().timeIntervalSince1970)
        
        FirestoreService.shared.saveDocument(collectionId: .notifications, data: receiverNoti)
    }
}
