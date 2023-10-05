//
//  LikeViewViewModel.swift
//  Pico
//
//  Created by 방유빈 on 2023/10/04.
//

import Foundation
import RxSwift
import RxRelay

final class LikeMeViewViewModel {
    
    var likeMeUserList = BehaviorRelay<[User]>(value: [])
    var likeMeIsEmpty: Observable<Bool> {
        return likeMeUserList
            .map { $0.isEmpty }
            .distinctUntilChanged()
    }
    var deleteButtonTapUser: PublishSubject<User> = PublishSubject()
    
    private let disposeBag = DisposeBag()
    
    init() {
        likeMeUserList.accept(UserDummyData.users)
    }
    
    func bindDeleteButtonTap() {
        deleteButtonTapUser
            .subscribe(onNext: { [weak self] user in
                self?.deleteUser(user: user)
            })
            .disposed(by: disposeBag)
    }
    
    private func deleteUser(user: User) {
        let updatedUsers = likeMeUserList.value.filter { $0.id != user.id }
        likeMeUserList.accept(updatedUsers)
    }
}
