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
    var selectedUser: User
    private let pageSize = 12
    var startIndex = 0
    
    private(set) var likeList: [Like.LikeInfo] = [] {
        didSet {
            reloadPublisher.onNext(())
        }
    }
    private let reloadPublisher = PublishSubject<Void>()
    
    init(selectedUser: User) {
        self.selectedUser = selectedUser
    }
    
    struct Input {
        let selectedRecordType: Observable<RecordType>
        let isUnsubscribe: Observable<Void>
    }
    
    struct Output {
        let currentRecordType: Observable<RecordType>
        let resultIsUnsubscribe: Observable<Void>
        let needToReload: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        let responseRecordType = input.selectedRecordType
            .withUnretained(self)
            .map { viewModel, recordType in
                switch recordType {
                case .report:
                    break
                case .block:
                    break
                case .like:
                    viewModel.fetchLikeUser() { likelist in
                        guard let likelist else { return }
                        viewModel.likeList = likelist
                    }
                case .payment:
                    break
                }
                return recordType
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
            currentRecordType: responseRecordType,
            resultIsUnsubscribe: responseUnsubscribe,
            needToReload: reloadPublisher.asObservable()
        )
    }
    
    private func fetchLikeUser(completion: @escaping ([Like.LikeInfo]?) -> ()) {
        let dbRef = Firestore.firestore()
        let ref = dbRef.collection(Collections.likes.name).document(selectedUser.id)
        let endIndex = startIndex + pageSize
        
        DispatchQueue.global().async {
            ref.getDocument { [weak self] document, error in
                guard let self = self else { return }
                if let error = error {
                    completion(nil)
                    return
                }
                
                if let document = document, document.exists {
                    if let datas = try? document.data(as: Like.self).recivedlikes?.filter({ $0.likeType == .like }) {
                        if startIndex > datas.count - 1 {
                            return
                        }
                        let currentPageDatas: [Like.LikeInfo] = Array(datas[startIndex..<min(endIndex, datas.count)])
                        likeList.append(contentsOf: currentPageDatas)
                        startIndex += currentPageDatas.count
                        completion(likeList)
                    }
                } else {
                    completion([])
                }
            }
        }
    }
}
