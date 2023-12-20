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
    
    private var itemsPerPage: Int = Int(Screen.height * 1.5 / 60)
    var lastDocumentSnapshot: DocumentSnapshot?
    var startIndex = 0
    var roomId: String?
    
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
                viewModel.loadNextChattingPage()
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
    
    func loadNextChattingPage() {
        let ref = dbRef.collection("room").document(roomId ?? "")
        
        let endIndex = startIndex + itemsPerPage
        
        DispatchQueue.global().async {
            ref.getDocument { [weak self] document, error in
                guard let self = self else { return }
                if let error = error {
                    print(error)
                    return
                }
                
                if let document = document, document.exists {
                    if let datas = try? document.data(as: Chatting.self).userChatting {
                        let sorted = datas.sorted {
                            return $0.sendedDate > $1.sendedDate
                        }
                        if startIndex > sorted.count - 1 {
                            return
                        }
                        let currentPageDatas: [Chatting.ChattingInfo] = Array(sorted[startIndex..<min(endIndex, sorted.count)])
                        chattingList += currentPageDatas
                        
                        if startIndex == 0 {
                            reloadChattingTableViewPublisher.onNext(())
                        }
                        
                        startIndex += currentPageDatas.count
                    }
                } else {
                    print("받은 문서를 찾을 수 없습니다.")
                }
            }
        }
    }
    
    private func refresh() {
        let didSet = isChattingEmptyPublisher
        isChattingEmptyPublisher = PublishSubject<Bool>()
        chattingList = []
        startIndex = 0
        isChattingEmptyPublisher = didSet
        loadNextChattingPage()
    }
    
}
// MARK: - saveChatting
extension ChattingViewModel {
    func saveChattingData(receiveUserId: String, message: String, type: ChattingSendType) {
        
        let senderUser = UserDefaultsManager.shared.getUserData()
        let roomId = UUID().uuidString
        
        saveSender(roomId: roomId, receiveUserId: receiveUserId, message: message, type: type)
        saveReceiver(roomId: roomId, receiveUserId: receiveUserId, message: message)
        
        guard let senderMbti = MBTIType(rawValue: senderUser.mbti) else { return }
        
        let receiverNoti = Noti(receiveId: receiveUserId, sendId: senderUser.userId, name: senderUser.nickName, birth: senderUser.birth, imageUrl: senderUser.imageURL, notiType: .message, mbti: senderMbti, createDate: Date().timeIntervalSince1970)
        
        FirestoreService.shared.saveDocument(collectionId: .notifications, data: receiverNoti)
        
        print("매칭 데이터 업데이트 완료")
    }
    
    private func saveSender(roomId: String, receiveUserId: String, message: String, type: ChattingSendType) {
        let senderUser = UserDefaultsManager.shared.getUserData()
        let senderDBRef = dbRef.collection(Collections.chatting.name).document(senderUser.userId)
        
        let sendMessages: [String: Any] = [
            "id": UUID().uuidString,
            "roomId": roomId,
            "sendUserId": senderUser.userId,
            "receiveUserId": receiveUserId,
            "message": message,
            "sendedDate": Date().timeIntervalSince1970,
            "isReading": true
        ]
        
        let matchingReceiveMessages: [String: Any] = [
            "id": UUID().uuidString,
            "roomId": roomId,
            "sendUserId": receiveUserId,
            "receiveUserId": senderUser.userId,
            "message": message,
            "sendedDate": Date().timeIntervalSince1970,
            "isReading": false
        ]
        
        let sendRoomMessages: [String: Any] = [
            "roomId": roomId,
            "opponentId": receiveUserId,
            "lastMessage": message,
            "sendedDate": Date().timeIntervalSince1970
        ]
        
        DispatchQueue.global().async {
            
            senderDBRef.setData(
                [
                    "userId": senderUser.userId,
                    "room": FieldValue.arrayUnion([sendRoomMessages])
                ], merge: true) { error in
                    if let error = error {
                        print("룸 데이터 업데이트 에러: \(error)")
                    }
                }
            
            if type == .chatting { // 메시지를 보내는 경우
                // 보내는 사람
                senderDBRef.collection("room").document(roomId).setData(
                    [
                        "userId": senderUser.userId,
                        "userChatting": FieldValue.arrayUnion([sendMessages])
                    ], merge: true) { error in
                        if let error = error {
                            print("매칭 채팅 업데이트 에러: \(error)")
                        }
                    }
                
                NotificationService.shared.sendNotification(userId: receiveUserId, sendUserName: senderUser.nickName, notiType: .message, messageContent: message)
                
            } else { // 매칭의 경우
                senderDBRef.collection("room").document(roomId).setData(
                    [
                        "userId": senderUser.userId,
                        "userChatting": FieldValue.arrayUnion([matchingReceiveMessages])
                    ], merge: true) { error in
                        if let error = error {
                            print("평가 업데이트 에러: \(error)")
                        }
                    }
            }
        }
    }
    
    private func saveReceiver(roomId: String, receiveUserId: String, message: String) {
        let senderUser = UserDefaultsManager.shared.getUserData()
        let receiveDBRef = dbRef.collection(Collections.chatting.name).document(receiveUserId)
        
        let receiveMessages: [String: Any] = [
            "id": UUID().uuidString,
            "roomId": roomId,
            "sendUserId": senderUser.userId,
            "receiveUserId": receiveUserId,
            "message": message,
            "sendedDate": Date().timeIntervalSince1970,
            "isReading": false
        ]
        
        let receiveRoomMessages: [String: Any] = [
            "roomId": roomId,
            "opponentId": senderUser.userId,
            "lastMessage": message,
            "sendedDate": Date().timeIntervalSince1970
        ]
        
        DispatchQueue.global().async {
            
            receiveDBRef.setData(
                [
                    "userId": receiveUserId,
                    "room": FieldValue.arrayUnion([receiveRoomMessages])
                ], merge: true) { error in
                    if let error = error {
                        print("보내기 업데이트 에러: \(error)")
                    }
                }
            
            // 받는 사람
            receiveDBRef.collection("room").document(roomId).setData(
                [
                    "userId": receiveUserId,
                    "userChatting": FieldValue.arrayUnion([receiveMessages])
                ], merge: true) { error in
                    if let error = error {
                        print("받은사람 보내기 업데이트 에러: \(error)")
                    }
                }
        }
    }
}
