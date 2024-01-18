//
//  RoomViewModel.swift
//  Pico
//
//  Created by 양성혜 on 2023/12/20.
//

import UIKit
import RxSwift
import RxRelay
import FirebaseFirestore

final class RoomViewModel {
    
    private(set) var roomList: [ChatRoom.RoomInfo] = [] {
        didSet {
            if roomList.isEmpty {
                isRoomEmptyPublisher.onNext(true)
            } else {
                isRoomEmptyPublisher.onNext(false)
            }
        }
    }
    
    private var isRoomEmptyPublisher = PublishSubject<Bool>()
    private let reloadRoomTableViewPublisher = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    
    private let dbRef = Firestore.firestore()
    
    private var itemsPerPage: Int = Int(Screen.height * 1.5 / 60)
    var startIndex = 0
    
    struct Input {
        let listLoad: Observable<Void>
        let refresh: Observable<Void>
        let isRoomEmptyChecked: Observable<Void>
    }
    
    struct Output {
        let roomIsEmpty: Observable<Bool>
        let reloadRoomTableView: Observable<Void>
    }
    
    private func refresh() {
        let didSet = isRoomEmptyPublisher
        isRoomEmptyPublisher = PublishSubject<Bool>()
        roomList = []
        startIndex = 0
        isRoomEmptyPublisher = didSet
        loadNextRoomPage()
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
                viewModel.loadNextRoomPage()
            }
            .disposed(by: disposeBag)
        
        let didRoomset = isRoomEmptyPublisher.asObservable()
            .map { result in
                return result
            }
        let roomCheck = input.isRoomEmptyChecked
            .withUnretained(self)
            .map { viewModel, _ -> Bool in
                if viewModel.roomList.isEmpty {
                    return true
                } else {
                    return false
                }
            }
        let isRoomEmpty = Observable.of(didRoomset, roomCheck).merge()
            .flatMapLatest { bool -> Observable<Bool> in
                return Observable.create { emitter in
                    emitter.onNext(bool)
                    return Disposables.create()
                }
            }
        
        return Output(
            roomIsEmpty: isRoomEmpty,
            reloadRoomTableView: reloadRoomTableViewPublisher.asObservable()
        )
    }
    
    func loadNextRoomPage() {
        let ref = dbRef.collection(Collections.chatRoom.name)
            .document(UserDefaultsManager.shared.getUserData().userId)
        
        let endIndex = startIndex + itemsPerPage
        
        DispatchQueue.global().async {
            ref.addSnapshotListener { [self] documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                if let datas = try? document.data(as: ChatRoom.self).roomInfo {
                    let sorted = datas.sorted {
                        return $0.sendedDate > $1.sendedDate
                    }
                    if startIndex > sorted.count - 1 {
                        return
                    }
                    let currentPageDatas: [ChatRoom.RoomInfo] = Array(sorted[startIndex..<min(endIndex, sorted.count)])
                    roomList += currentPageDatas
                    
                    if startIndex == 0 {
                        reloadRoomTableViewPublisher.onNext(())
                    }
                    
                    startIndex += currentPageDatas.count
                }
            }
        }
    }
}
