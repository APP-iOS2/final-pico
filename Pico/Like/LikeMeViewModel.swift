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
        guard let index = likeMeUserList.value.firstIndex(where: {
            $0.likedUserId == userId
        }) else {
            return
        }
        guard let likeData: Like.LikeInfo = likeMeUserList.value[safe: index] else { return }
        let updateData: Like.LikeInfo = Like.LikeInfo(likedUserId: likeData.likedUserId, likeType: .matching, birth: likeData.birth, nickName: likeData.nickName, mbti: likeData.mbti, imageURL: likeData.imageURL)
        
        dbRef.collection(Collections.likes.name).document(currentUser.userId).updateData([
            "recivedlikes": FieldValue.arrayRemove([likeData.asDictionary()])
        ])
        dbRef.collection(Collections.likes.name).document(currentUser.userId).updateData([
            "recivedlikes": FieldValue.arrayUnion([updateData.asDictionary()])
        ])
        dbRef.collection(Collections.likes.name).document(currentUser.userId).updateData([
            "sendedlikes": FieldValue.arrayUnion([updateData.asDictionary()])
        ])
        let updatedDatas = likeMeUserList.value.filter { $0.likedUserId != userId }
        likeMeUserList.accept(updatedDatas)

        var tempLike: Like?
        FirestoreService.shared.loadDocument(collectionId: .likes, documentId: likeData.likedUserId, dataType: Like.self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                tempLike = data
                guard let tempLike = tempLike else {
                    return
                }
                
                guard let sendedlikes = tempLike.sendedlikes else { return }
                guard let sendIndex = sendedlikes.firstIndex(where: {
                    $0.likedUserId == self.currentUser.userId
                }) else {
                    return
                }
                
                guard let tempSendLike = sendedlikes[safe: sendIndex] else { return }
                let updateSendLike = Like.LikeInfo(likedUserId: tempSendLike.likedUserId, likeType: .matching, birth: tempSendLike.birth, nickName: tempSendLike.nickName, mbti: tempSendLike.mbti, imageURL: tempSendLike.imageURL)
                dbRef.collection(Collections.likes.name).document(likeData.likedUserId).updateData([
                    "sendedlikes": FieldValue.arrayRemove([tempSendLike.asDictionary()])
                ])
                dbRef.collection(Collections.likes.name).document(likeData.likedUserId).updateData([
                    "sendedlikes": FieldValue.arrayUnion([updateSendLike.asDictionary()])
                ])
                dbRef.collection(Collections.likes.name).document(likeData.likedUserId).updateData([
                    "recivedlikes": FieldValue.arrayUnion([updateSendLike.asDictionary()])
                ])
                
                let myNoti = Noti(receiveId: currentUser.userId, name: likeData.nickName, birth: likeData.birth, imageUrl: likeData.imageURL, notiType: .matching, mbti: likeData.mbti, createDate: Date().timeIntervalSince1970)
                
                guard let yourMbti = MBTIType(rawValue: currentUser.mbti) else { return }
                let yourNoti = Noti(receiveId: likeData.likedUserId, name: currentUser.nickName, birth: currentUser.birth, imageUrl: currentUser.imageURL, notiType: .matching, mbti: yourMbti, createDate: Date().timeIntervalSince1970)
                FirestoreService.shared.saveDocument(collectionId: .notifications, data: myNoti)
                FirestoreService.shared.saveDocument(collectionId: .notifications, data: yourNoti)
            case .failure(let error):
                print(error)
                return
            }
        }
    }
}
