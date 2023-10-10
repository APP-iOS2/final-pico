//
//  AdminViewModel.swift
//  Pico
//
//  Created by 최하늘 on 10/6/23.
//

import Foundation
import RxSwift
import RxCocoa

final class AdminViewModel {
    let userList = BehaviorRelay<[User]>(value: [])
    
    init() {
        FirestoreService.shared.loadDocuments(collectionId: .users, dataType: User.self) { [weak self] result in
            switch result {
            case .success(let user):
                self?.userList.accept(user)
            case .failure(let error):
                print(error)
            }
        }
    }
}
