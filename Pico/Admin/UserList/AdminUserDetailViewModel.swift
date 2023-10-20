//
//  AdminUserDetailViewModel.swift
//  Pico
//
//  Created by 최하늘 on 10/15/23.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseFirestore

final class AdminUserDetailViewModel: ViewModelType {
    struct Input {
        let selectedRecordType: Observable<RecordType>
        let refreshable: Observable<RecordType>
        let isUnsubscribe: Observable<Void>
    }
    
    struct Output {
        let needToFirstLoad: Observable<RecordType>
        let needToRefresh: Observable<RecordType>
        let resultIsUnsubscribe: Observable<Void>
        let needToReload: Observable<Void>
    }
    
    var selectedUser: User
    private var startLikeIndex = 0
    private let pageSize = 10
    
    private(set) var likeList: [Like.LikeInfo] = []
    private let reloadPublisher = PublishSubject<Void>()
    
    init(selectedUser: User) {
        self.selectedUser = selectedUser
    }
    
    func transform(input: Input) -> Output {
        let responseLoad = input.selectedRecordType
            .withUnretained(self)
            .flatMapLatest { viewModel, recordType in
                viewModel.startLikeIndex = 0
                viewModel.likeList.removeAll()
                
                switch recordType {
                case .report:
                    return Observable<RecordType>.just(recordType)
                case .block:
                    return Observable<RecordType>.just(recordType)
                case .like:
                    return viewModel.fetchLikeUser()
                        .map { _ in
                            return recordType
                        }
                case .payment:
                    return Observable<RecordType>.just(recordType)
                }
            }
        
        let responseRefresh = input.refreshable
            .withUnretained(self)
            .flatMapLatest { viewModel, recordType in
                switch recordType {
                case .report:
                    return Observable<RecordType>.just(recordType)
                case .block:
                    return Observable<RecordType>.just(recordType)
                case .like:
                    return viewModel.fetchLikeUser()
                        .map { _ in
                            return recordType
                        }
                case .payment:
                    return Observable<RecordType>.just(recordType)
                }
            }
        
        let responseUnsubscribe = input.isUnsubscribe
            .withUnretained(self)
            .flatMap { viewModel, _ in
                return FirestoreService.shared.saveDocumentRx(collectionId: .unsubscribe, documentId: viewModel.selectedUser.id, data: viewModel.selectedUser)
            }
            .withUnretained(self)
            .flatMap { viewModel, _ in
                return FirestoreService.shared.removeDocumentRx(collectionId: .users, documentId: viewModel.selectedUser.id)
            }
        
        return Output(
            needToFirstLoad: responseLoad,
            needToRefresh: responseRefresh,
            resultIsUnsubscribe: responseUnsubscribe,
            needToReload: reloadPublisher.asObservable()
        )
    }
    
    private func fetchLikeUser() -> Observable<[Like.LikeInfo]> {
        return Observable.create { [weak self] observer in
            guard let self else { return Disposables.create() }
            let dbRef = Firestore.firestore()
            let ref = dbRef.collection(Collections.likes.name).document(selectedUser.id)
            let endIndex = startLikeIndex + pageSize
            
            DispatchQueue.global().async {
                ref.getDocument { [weak self] document, error in
                    guard let self = self else { return }
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    
                    if let document = document, document.exists {
                        if let datas = try? document.data(as: Like.self).recivedlikes?.filter({ $0.likeType == .like }) {
                            if startLikeIndex > datas.count - 1 {
                                observer.onNext([])
                            } else {
                                let currentPageDatas: [Like.LikeInfo] = Array(datas[startLikeIndex..<min(endIndex, datas.count)])
                                likeList.append(contentsOf: currentPageDatas)
                                startLikeIndex += currentPageDatas.count
                                observer.onNext(self.likeList)
                            }
                        }
                    } else {
                        observer.onNext([])
                    }
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
}
