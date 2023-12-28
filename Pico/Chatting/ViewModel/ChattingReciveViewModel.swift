//
//  ChattingReciveViewModel.swift
//  Pico
//
//  Created by 양성혜 on 2023/12/28.
//

import UIKit
import RxSwift
import RxRelay
import FirebaseFirestore

final class ChattingReciveViewModel {
    
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
                    if let datas = try? document.data(as: Chatting.self).receiverChatting?
                        .filter({ $0.roomId == self.roomId}) {
                        let sorted = datas.sorted {
                            return $0.sendedDate < $1.sendedDate
                        }
                        if startIndex > sorted.count - 1 {
                            return
                        }
                        let currentPageDatas: [Chatting.ChattingInfo] = Array(sorted[startIndex..<min(endIndex, sorted.count)])
                        receiveChattingList += currentPageDatas
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
        startIndex = 0
        isChattingEmptyPublisher = didSet
        loadNextChattingPage()
    }
}
