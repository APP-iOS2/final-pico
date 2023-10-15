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
        let refresh: Observable<Bool>
    }
    
    struct Output {
        let resultToLikeUList: Observable<[Like.LikeInfo]>
        let likeUIsEmpty: Observable<Bool>
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
    private let isEmptyPublisher = PublishSubject<Bool>()
    var sendViewConnectSubject: PublishSubject<User> = PublishSubject()
    
    private let disposeBag = DisposeBag()
    private let currentUser = UserDefaultsManager.shared.getUserData()
    private let pageSize = 6
    var startIndex = 0

    func transform(input: Input) -> Output {
        input.refresh
            .withUnretained(self)
            .subscribe { viewModel, _ in
                viewModel.refresh()
            }
            .disposed(by: disposeBag)
        
        let responseReady = input.listLoad
            .flatMap { _ -> Observable<[Like.LikeInfo]> in
                return Observable.create { [weak self] emitter in
                    self?.loadNextPage { result in
                        switch result {
                        case .success(let data):
                            emitter.onNext(data)
                        case .failure(let error):
                            emitter.onError(error)
                        }
                    }
                    return Disposables.create()
                }
            }
            .withUnretained(self)
            .map { viewModel, likeList in
                viewModel.likeUList.append(contentsOf: likeList)
                return viewModel.likeUList
            }
        
        return Output(resultToLikeUList: responseReady, likeUIsEmpty: isEmptyPublisher.asObservable())
    }
    private func loadNextPage(completion: @escaping (Result<[Like.LikeInfo], Error>) -> Void) {
        let dbRef = Firestore.firestore()
        let ref = dbRef.collection(Collections.likes.name).document(currentUser.userId)
        let endIndex = startIndex + pageSize
        
        ref.getDocument { [weak self] document, error in
            guard let self = self else { return }
            if let error = error {
                completion(.failure(error))
            }
            
            var tempList: [Like.LikeInfo] = []
            if let document = document, document.exists {
                if let datas = try? document.data(as: Like.self).sendedlikes?.filter({ $0.likeType == .like }) {
                    if startIndex > datas.count - 1 {
                        return
                    }
                    let currentPageDatas: [Like.LikeInfo] = Array(datas[startIndex..<min(endIndex, datas.count)])
                    tempList.append(contentsOf: currentPageDatas)
                    startIndex += currentPageDatas.count
                    completion(.success(tempList))
                }
            } else {
                completion(.failure(LikeUError.notFound))
            }
        }
    }
    
    private func refresh() {
        likeUList = []
        startIndex = 0
    }
}
