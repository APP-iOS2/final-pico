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
    var deleteButtonTapUser: PublishSubject<User> = PublishSubject()
    
    private let disposeBag = DisposeBag()
    
    init() {
        FirestoreService.shared.loadDocumentRx(collectionId: .likes, documentId: "cJDnaz3Yn6lQBa9nZSpH", dataType: Like.self)
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
        bindDeleteButtonTap()
    }
    
    private func bindDeleteButtonTap() {
        deleteButtonTapUser
            .subscribe(onNext: { [weak self] user in
                self?.deleteUser(user: user)
            })
            .disposed(by: disposeBag)
    }
    
    private func deleteUser(user: User) {
        let updatedUsers = likeMeUserList.value.filter { $0.likedUserId != user.id }
        likeMeUserList.accept(updatedUsers)
    }
}
