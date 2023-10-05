//
//  LikeUViewViewModel.swift
//  Pico
//
//  Created by 방유빈 on 2023/10/05.
//

import Foundation
import RxSwift
import RxRelay

class LikeUViewViewModel {
    var likeUUserList = BehaviorRelay<[User]>(value: [])
    var likeUIsEmpty: Observable<Bool> {
        return likeUUserList
            .map { $0.isEmpty }
            .distinctUntilChanged()
    }
    var messageButtonTapUser: PublishSubject<User> = PublishSubject()
    
    private let disposeBag = DisposeBag()
    
    init() {
        likeUUserList.accept(UserDummyData.users)
    }
}
