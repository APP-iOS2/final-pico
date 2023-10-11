//
//  LikeViewViewModel.swift
//  Pico
//
//  Created by 방유빈 on 2023/10/04.
//

import Foundation
import RxSwift
import RxRelay

final class LikeMeViewModel {
    var likeMeUserList = BehaviorRelay<[Like.LikeInfo]>(value: [])
    var likeMeIsEmpty: Observable<Bool> {
        return likeMeUserList
            .map { $0.isEmpty }
    }
    
    private let disposeBag = DisposeBag()
    
    init() {
        FirestoreService.shared.loadDocumentRx(collectionId: .likes, documentId: UserDefaultsManager.shared.getUserData().userId, dataType: Like.self)
            .map { like -> [Like.LikeInfo] in
                if let like = like {
                    return like.recivedlikes ?? []
                }
                return []
            }
            .map({ likeInfos in
                return likeInfos.filter { $0.likeType == .like }
            })
            .bind(to: likeMeUserList)
            .disposed(by: disposeBag)
    }
    
   func deleteUser(userId: String) {
        let updatedUsers = likeMeUserList.value.filter { $0.likedUserId != userId }
        likeMeUserList.accept(updatedUsers)
    }
}
