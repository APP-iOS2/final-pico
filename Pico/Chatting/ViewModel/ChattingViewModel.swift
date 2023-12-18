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
    var lastDocumentSnapshot: DocumentSnapshot?
    private var itemsPerPage: Int = Int(Screen.height * 1.5 / 60)
    var startIndex = 0
    
    struct Input {
        let listLoad: Observable<Void>
        //let deleteUser: Observable<String>
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
        
//        input.deleteUser
//            .withUnretained(self)
//            .subscribe { viewModel, chattingId in
//                viewModel.deleteChatting(chattingId: chattingId)
//            }
//            .disposed(by: disposeBag)
        
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
        let dbRef = Firestore.firestore().collection(Collections.chatting.name).document(UserDefaultsManager.shared.getUserData().userId)
        
        var query = dbRef.collection("room")
            .whereField("sendUserId", isEqualTo: UserDefaultsManager.shared.getUserData().userId)
            .order(by: "createDate", descending: true)
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
        loadNextChattingPage()
    }
    
    func updateNewData(data: Chatting.ChattingInfo) {
        let updateData: Chatting.ChattingInfo = data
        
        DispatchQueue.global().async {
            self.dbRef.collection(Collections.chatting.name).document(UserDefaultsManager.shared.getUserData().userId).collection("room").document(data.roomID).updateData([
                "chattingInfo": FieldValue.arrayRemove([data.asDictionary()])
            ])
            self.dbRef.collection(Collections.chatting.name).document(UserDefaultsManager.shared.getUserData().userId).collection("room").document(data.roomID).updateData([
                "chattingInfo": FieldValue.arrayUnion([updateData.asDictionary()])
            ])
        }
    }
}
