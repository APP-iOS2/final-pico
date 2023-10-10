//
//  HomeViewModel.swift
//  Pico
//
//  Created by 임대진 on 10/5/23.
//
import RxSwift
import RxRelay
import Foundation

final class HomeViewModel {
    var users = BehaviorRelay<[User]>(value: [])
    private let disposeBag = DisposeBag()
    
    init() {
        loadUsersRx()
    }
    
    func loadUsersRx() {
        FirestoreService.shared.loadDocumentRx(collectionId: .users, dataType: User.self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                self?.users.accept(data)
            }, onError: { error in
                print("오류: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    func loadUsers() {
        FirestoreService.shared.loadDocuments(collectionId: .users, dataType: User.self) { result in
            switch result {
            case .success(let data):
                self.users.accept(data)
            case .failure(let error):
                print("오류: \(error)")
            }
        }
    }
}
