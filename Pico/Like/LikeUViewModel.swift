//
//  LikeUViewViewModel.swift
//  Pico
//
//  Created by 방유빈 on 2023/10/05.
//

import RxSwift
import RxRelay
import UIKit

final class LikeUViewModel {
    var likeUUserList = BehaviorRelay<[Like.LikeInfo]>(value: [])
    var likeUIsEmpty: Observable<Bool> {
        return likeUUserList
            .map { $0.isEmpty }
    }
    
    var sendViewConnectSubject: PublishSubject<User> = PublishSubject()
    
    private let disposeBag = DisposeBag()
    
    init() {
        FirestoreService.shared.loadDocumentRx(collectionId: .likes, documentId: UserDefaultsManager.shared.getUserData().userId, dataType: Like.self)
            .map { like -> [Like.LikeInfo] in
                if let like = like {
                    return like.sendedlikes ?? []
                }
                return []
            }
            .map({ likeInfos in
                return likeInfos.filter { $0.likeType == .like }
            })
            .bind(to: likeUUserList)
            .disposed(by: disposeBag)
    }
}
