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
    var likeMeList: [Like.LikeInfo] = []
    var likeMeListRx = BehaviorRelay<[Like.LikeInfo]>(value: [])
    var likeMeIsEmpty: Observable<Bool> {
        return likeMeListRx
            .map { $0.isEmpty }
    }
    
    private let disposeBag = DisposeBag()
    private let currentUser: CurrentUser = UserDefaultsManager.shared.getUserData()
    private let dbRef = Firestore.firestore()
    private let pageSize = 6
    var startIndex = 0
    
    init() {
        loadNextPage()
    }
    
    func loadNextPage() {
        let dbRef = Firestore.firestore()
        let ref = dbRef.collection(Collections.likes.name).document(currentUser.userId)
        let endIndex = startIndex + pageSize
        
        ref.getDocument { [weak self] document, error in
            guard let self = self else { return }
            if let error = error {
                print(error)
                return
            }
            
            if let document = document, document.exists {
                if let datas = try? document.data(as: Like.self).recivedlikes?.filter({ $0.likeType == .like }) {
                    if startIndex > datas.count - 1 {
                        return
                    }
                    let currentPageDatas: [Like.LikeInfo] = Array(datas[startIndex..<min(endIndex, datas.count)])
                    likeMeList.append(contentsOf: currentPageDatas)
                    startIndex += currentPageDatas.count
                    likeMeListRx.accept(likeMeList)
                }
            } else {
                print("문서를 찾을 수 없습니다.")
            }
        }
    }
    
    func refrsh() {
        likeMeList = []
        startIndex = 0
        loadNextPage()
    }
 
    func deleteUser(userId: String) {
        guard let index = likeMeListRx.value.firstIndex(where: {
            $0.likedUserId == userId
        }) else {
            return
        }
        likeMeList.remove(at: index)
        guard let removeData: Like.LikeInfo = likeMeListRx.value[safe: index] else { return }
        let updateData: Like.LikeInfo = Like.LikeInfo(likedUserId: removeData.likedUserId, likeType: .dislike, birth: removeData.birth, nickName: removeData.nickName, mbti: removeData.mbti, imageURL: removeData.imageURL, createdDate: Date().timeIntervalSince1970)
        
        dbRef.collection(Collections.likes.name).document(currentUser.userId).updateData([
            "recivedlikes": FieldValue.arrayRemove([removeData.asDictionary()])
        ])
        dbRef.collection(Collections.likes.name).document(currentUser.userId).updateData([
            "recivedlikes": FieldValue.arrayUnion([updateData.asDictionary()])
        ])
        
        let updatedDatas = likeMeListRx.value.filter { $0.likedUserId != userId }
        likeMeListRx.accept(updatedDatas)
        
    }
    
    func likeUser(userId: String) {
        guard let index = likeMeListRx.value.firstIndex(where: {
            $0.likedUserId == userId
        }) else {
            return
        }
        likeMeList.remove(at: index)
        guard let likeData: Like.LikeInfo = likeMeListRx.value[safe: index] else { return }
        let updateData: Like.LikeInfo = Like.LikeInfo(likedUserId: likeData.likedUserId, likeType: .matching, birth: likeData.birth, nickName: likeData.nickName, mbti: likeData.mbti, imageURL: likeData.imageURL, createdDate: Date().timeIntervalSince1970)
        
        dbRef.collection(Collections.likes.name).document(currentUser.userId).updateData([
            "recivedlikes": FieldValue.arrayRemove([likeData.asDictionary()])
        ])
        dbRef.collection(Collections.likes.name).document(currentUser.userId).updateData([
            "recivedlikes": FieldValue.arrayUnion([updateData.asDictionary()])
        ])
        dbRef.collection(Collections.likes.name).document(currentUser.userId).updateData([
            "sendedlikes": FieldValue.arrayUnion([updateData.asDictionary()])
        ])
        let updatedDatas = likeMeListRx.value.filter { $0.likedUserId != userId }
        likeMeListRx.accept(updatedDatas)

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
                let updateSendLike = Like.LikeInfo(likedUserId: tempSendLike.likedUserId, likeType: .matching, birth: tempSendLike.birth, nickName: tempSendLike.nickName, mbti: tempSendLike.mbti, imageURL: tempSendLike.imageURL, createdDate: Date().timeIntervalSince1970)
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
