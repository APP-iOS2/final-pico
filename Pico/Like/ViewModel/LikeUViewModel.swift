//
//  LikeUViewViewModel.swift
//  Pico
//
//  Created by 방유빈 on 2023/10/05.
//

import RxSwift
import UIKit
import FirebaseFirestore

final class LikeUViewModel: ViewModelType {
    enum LikeUError: Error {
        case notFound
    }
    struct Input {
        let listLoad: Observable<Void>
        let refresh: Observable<Void>
        let checkEmpty: Observable<Void>
        let sendMessage: Observable<(Int)>
    }
    
    struct Output {
        let likeUIsEmpty: Observable<Bool>
        let reloadCollectionView: Observable<Void>
        let resultMessage: Observable<Void>
    }
    
    private(set) var likeUList: [Like.LikeInfo] = [] {
        didSet {
            if likeUList.isEmpty {
                isEmptyPublisher.onNext(true)
            } else {
                isEmptyPublisher.onNext(false)
            }
        }
    }
    
    private var isEmptyPublisher = PublishSubject<Bool>()
    private let reloadCollectionViewPublisher = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    private let currentUser = UserDefaultsManager.shared.getUserData()
    private var currentChuCount = UserDefaultsManager.shared.getChuCount()
    private let pageSize = 10
    var startIndex = 0
    
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
                viewModel.loadNextPage()
            }
            .disposed(by: disposeBag)
        
        let didset = isEmptyPublisher.asObservable()
            .map { result in
                return result
            }
        
        let check = input.checkEmpty
            .withUnretained(self)
            .map { viewModel, _ -> Bool in
                if viewModel.likeUList.isEmpty {
                    return true
                } else {
                    return false
                }
            }
        
        let isEmpty = Observable.of(didset, check).merge()
            .flatMapLatest { bool -> Observable<Bool> in
                return Observable.create { emitter in
                    emitter.onNext(bool)
                    return Disposables.create()
                }
            }
        
        let resultMessage = input.sendMessage
            .withUnretained(self)
            .flatMap { viewModel, chu in
                viewModel.currentChuCount = UserDefaultsManager.shared.getChuCount() - 50
                return FirestoreService.shared.updateDocumentRx(collectionId: .users, documentId: viewModel.currentUser.userId, field: "chuCount", data: viewModel.currentChuCount)
                    .flatMap { _ -> Observable<Void> in
                        let payment: Payment.PaymentInfo = Payment.PaymentInfo(price: 0, purchaseChuCount: -chu, paymentType: .mail)
                        return FirestoreService.shared.saveDocumentRx(collectionId: .payment, documentId: viewModel.currentUser.userId, fieldId: "paymentInfos", data: payment)
                    }
            }
            .withUnretained(self)
            .map { viewModel, _ in
                UserDefaultsManager.shared.updateChuCount(viewModel.currentChuCount)
            }
        
        return Output(likeUIsEmpty: isEmpty, reloadCollectionView: reloadCollectionViewPublisher.asObservable(), resultMessage: resultMessage)
    }
    
    private func loadNextPage() {
        let dbRef = Firestore.firestore()
        let ref = dbRef.collection(Collections.likes.name).document(currentUser.userId)
        let endIndex = startIndex + pageSize
        FirestoreService.shared.loadDocuments(collectionId: .unsubscribe, dataType: Unsubscribe.self) { result in
            var unsubscribe = [Unsubscribe]()
            switch result {
            case .success(let data):
                unsubscribe = data
            case .failure(let error):
                print("탈퇴 회원 불러오기 실패: \(error)")
            }
            DispatchQueue.global().async {
                ref.getDocument { [weak self] document, error in
                    guard let self = self else { return }
                    if let error = error {
                        print(error)
                        return
                    }
                    
                    if let document = document, document.exists {
                        if let datas = try? document.data(as: Like.self).sendedlikes?.filter({ $0.likeType != .dislike }) {
                            var sorted = datas.sorted {
                                if $0.isMatch != $1.isMatch {
                                    return !$0.isMatch
                                } else {
                                    return $0.createdDate > $1.createdDate
                                }
                            }
                            sorted = sorted.filter { likeInfo in
                                let id = likeInfo.likedUserId
                                if id == Bundle.main.testId {
                                    return false
                                }
                                for unsubscribeUser in unsubscribe where unsubscribeUser.user.id == id {
                                    return false
                                }
                                return true
                            }
                            if startIndex > sorted.count - 1 {
                                return
                            }
                            let currentPageDatas: [Like.LikeInfo] = Array(sorted[0..<min(endIndex, sorted.count)])
                            likeUList = currentPageDatas
                            
                            if startIndex == 0 {
                                reloadCollectionViewPublisher.onNext(())
                            }
                            startIndex = currentPageDatas.count
                        }
                    } else {
                        print("문서를 찾을 수 없습니다.")
                    }
                }
            }
        }
    }
    
    private func refresh() {
        let didSet = isEmptyPublisher
        isEmptyPublisher = PublishSubject<Bool>()
        self.likeUList = []
        self.startIndex = 0
        isEmptyPublisher = didSet
        loadNextPage()
    }
}
