//
//  LikeViewViewModel.swift
//  Pico
//
//  Created by 방유빈 on 2023/10/04.
//

import Foundation
import RxSwift
import RxRelay
import FirebaseFirestore

final class LikeMeViewModel {
    var likeMeUserList = BehaviorRelay<[Like.LikeInfo]>(value: [])
    var likeMeIsEmpty: Observable<Bool> {
        return likeMeUserList
            .map { $0.isEmpty }
    }
    
    private let disposeBag = DisposeBag()
    private let currentUser: CurrentUser = UserDefaultsManager.shared.getUserData()
    private let dbRef = Firestore.firestore()
    
    init() {
        fetchLikeInfo()
    }
    
    func fetchLikeInfo() {
        FirestoreService.shared.loadDocumentRx(collectionId: .likes, documentId: currentUser.userId, dataType: Like.self)
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
        guard let index = likeMeUserList.value.firstIndex(where: {
            $0.likedUserId == userId
        }) else {
            return
        }
        guard let removeData: Like.LikeInfo = likeMeUserList.value[safe: index] else { return }
        let updateData: Like.LikeInfo = Like.LikeInfo(likedUserId: removeData.likedUserId, likeType: .dislike, birth: removeData.birth, nickName: removeData.nickName, mbti: removeData.mbti, imageURL: removeData.imageURL)
        
        dbRef.collection(Collections.likes.name).document(currentUser.userId).updateData([
            "recivedlikes": FieldValue.arrayRemove([removeData.asDictionary()])
        ])
        dbRef.collection(Collections.likes.name).document(currentUser.userId).updateData([
            "recivedlikes": FieldValue.arrayUnion([updateData.asDictionary()])
        ])
        
        let updatedDatas = likeMeUserList.value.filter { $0.likedUserId != userId }
        likeMeUserList.accept(updatedDatas)
        
    }
    
    func likeUser(userId: String) {
        var tempLike: Like?
        FirestoreService.shared.loadDocument(collectionId: .likes, documentId: currentUser.userId, dataType: Like.self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                tempLike = data
                guard let tempLike = tempLike else {
                    return
                }
                var newLikeInfos: [Like.LikeInfo] = tempLike.recivedlikes ?? []
                let index = newLikeInfos.firstIndex { $0.likedUserId == userId }
                guard let index = index else { return }
                let tempLikeInfo = newLikeInfos[index]
                let updateLikeInfo = Like.LikeInfo(likedUserId: tempLikeInfo.likedUserId, likeType: .matching, birth: tempLikeInfo.birth, nickName: tempLikeInfo.nickName, mbti: tempLikeInfo.mbti, imageURL: tempLikeInfo.imageURL)
                newLikeInfos = newLikeInfos.filter { $0.likedUserId != userId }
                
                likeMeUserList.accept(likeMeUserList.value.filter { $0.likedUserId != userId })
                
                newLikeInfos.append(updateLikeInfo)
                let newLike = Like(userId: currentUser.userId, sendedlikes: tempLike.sendedlikes, recivedlikes: newLikeInfos)
                dbRef.collection(Collections.likes.name).document(currentUser.userId).setData(newLike.asDictionary())
            case .failure(let error):
                print(error)
                return
            }
        }
    }
}
