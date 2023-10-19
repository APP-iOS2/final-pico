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
    
    private(set) var likeList: [Like.LikeInfo] = []
    private let reloadPublisher = PublishSubject<Void>()
    
    struct Input {
        let selectedRecordType: Observable<RecordType>
        let isUnsubscribe: Observable<Void>
    }
    
    struct Output {
        let resultIsUnsubscribe: Observable<Void>
        let needToReload: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        _ = input.selectedRecordType
            .map { type in
                return type
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
            resultIsUnsubscribe: responseUnsubscribe,
            needToReload: reloadPublisher.asObservable()
        )
    }
    
    init(selectedUser: User) {
        self.selectedUser = selectedUser
        loadNextPage()
    }
    
    private func loadNextPage() {
        let dbRef = Firestore.firestore()
        let ref = dbRef.collection(Collections.likes.name).document(selectedUser.id)
        let endIndex = startIndex + pageSize
        
        ref.getDocument { [weak self] document, error in
            guard let self = self else { return }
            if let error = error {
                print(error)
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
                    reloadPublisher.onNext(())
                }
            } else {
                print("문서를 찾을 수 없습니다.")
            }
        }
    }
}
