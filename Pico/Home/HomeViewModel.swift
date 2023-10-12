//
//  HomeViewModel.swift
//  Pico
//
//  Created by 임대진 on 10/5/23.
//
import RxSwift
import RxRelay
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class HomeViewModel {
    
    var users = BehaviorRelay<[User]>(value: [])
    var myLikes = BehaviorRelay<[Like.LikeInfo]>(value: [])
    var filterGender: [GenderType] = HomeFilterViewController.filterGender
    private let loginUser = UserDefaultsManager.shared.getUserData()
    private let disposeBag = DisposeBag()
    
    init() {
        loadUsers()
        loadMyLikesRx()
    }
    
    private func loadUsers() {
        DispatchQueue.global().async {
            let dbRef = Firestore.firestore()
            let query = dbRef.collection("users")
                .whereField("gender", in: self.filterGender.map { $0.rawValue })
                .whereField("id", isNotEqualTo: self.loginUser.userId)
            
            query.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print(error)
                } else {
                    var users = [User]()
                    for document in querySnapshot!.documents {
                        if let user = try? document.data(as: User.self) {
                            users.append(user)
                        }
                    }
                    self.users.accept(users)
                    
                }
            }
        }
    }
    private func loadMyLikesRx() {
        FirestoreService.shared.loadDocumentRx(collectionId: .likes, documentId: UserDefaultsManager.shared.getUserData().userId, dataType: Like.self)
            .map { like -> [Like.LikeInfo] in
                if let like = like {
                    return like.sendedlikes ?? []
                }
                return []
            }
            .bind(to: myLikes)
            .disposed(by: disposeBag)
    }
    
    //    func loadUsersRx() {
    //        FirestoreService.shared.loadDocumentRx(collectionId: .users, dataType: User.self)
    //            .observe(on: MainScheduler.instance)
    //            .bind(to: users)
    //            .disposed(by: disposeBag)
    //    }
    
    //    func loadUsers() {
    //        FirestoreService.shared.loadDocuments(collectionId: .users, dataType: User.self) { result in
    //            switch result {
    //            case .success(let data):
    //                self.users.accept(data)
    //            case .failure(let error):
    //                print("오류: \(error)")
    //            }
    //        }
    //    }
}
