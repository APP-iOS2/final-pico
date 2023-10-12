//
//  LikeUViewViewModel.swift
//  Pico
//
//  Created by 방유빈 on 2023/10/05.
//

import RxSwift
import RxRelay
import UIKit
import FirebaseFirestore

final class LikeUViewModel {
    var likeUList: [Like.LikeInfo] = []
    var likeUListRx = BehaviorRelay<[Like.LikeInfo]>(value: [])
    var likeUIsEmpty: Observable<Bool> {
        return likeUListRx
            .map { $0.isEmpty }
    }
    
    var sendViewConnectSubject: PublishSubject<User> = PublishSubject()
    
    private let disposeBag = DisposeBag()
    private let currentUser = UserDefaultsManager.shared.getUserData()
    private let pageSize = 6
    var startIndex = 0

    init() {
        loadNextPage()
    }
    
    func loadNextPage() {
        let dbRef = Firestore.firestore()
        let ref = dbRef.collection(Collections.likes.name).document(currentUser.userId)
        let endIndex = startIndex + pageSize
        
        ref.getDocument { [weak self] document, error in
            guard let self = self else { return }
            if let error = error {
                print(error)
                return
            }
            
            if let document = document, document.exists {
                if let datas = try? document.data(as: Like.self).sendedlikes?.filter({ $0.likeType == .like }) {
                    if startIndex > datas.count - 1 {
                        return
                    }
                    let currentPageDatas: [Like.LikeInfo] = Array(datas[startIndex..<min(endIndex, datas.count)])
                    likeUList.append(contentsOf: currentPageDatas)
                    startIndex += currentPageDatas.count
                    likeUListRx.accept(likeUList)
                }
            } else {
                print("문서를 찾을 수 없습니다.")
            }
        }
    }
    
    func refresh() {
        likeUList = []
        startIndex = 0
        loadNextPage()
    }
}
