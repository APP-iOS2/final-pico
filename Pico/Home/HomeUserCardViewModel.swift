//
//  HomeUserCardViewModel.swift
//  Pico
//
//  Created by 임대진 on 10/5/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class HomeUserCardViewModel {
    private let currentUser = UserDefaultsManager.shared.getUserData()
    private let currentChuCount = UserDefaultsManager.shared.getChuCount()
    private let sendedlikesUpdateFiled = "sendedlikes"
    private let recivedlikesUpdateFiled = "recivedlikes"
    private let docRef = Firestore.firestore().collection(Collections.likes.name)
    static var passedMyData: [[String: Any]] = []
    static var passedUserData: [[String: Any]] = []
    static var cardCounting: Int = 0
    
    func saveLikeData(receiveUserInfo: User, likeType: Like.LikeType) {
        let myLikeUser: Like.LikeInfo = Like.LikeInfo(likedUserId: receiveUserInfo.id,
                                                      likeType: likeType,
                                                      birth: receiveUserInfo.birth,
                                                      nickName: receiveUserInfo.nickName,
                                                      mbti: receiveUserInfo.mbti,
                                                      imageURL: receiveUserInfo.imageURLs[0],
                                                      createdDate: Date().timeIntervalSince1970)
            
        let myLikeUserDic = myLikeUser.asDictionary()
        let myInfo: Like.LikeInfo = Like.LikeInfo(likedUserId: currentUser.userId,
                                                  likeType: likeType,
                                                  birth: currentUser.birth,
                                                  nickName: currentUser.nickName,
                                                  mbti: MBTIType(rawValue: currentUser.mbti) ?? .entp,
                                                  imageURL: currentUser.imageURL,
                                                  createdDate: Date().timeIntervalSince1970)
        let myInfoDic = myInfo.asDictionary()
        HomeUserCardViewModel.passedMyData.append(myLikeUserDic)
        HomeUserCardViewModel.passedUserData.append(myInfoDic)
        
        docRef.document(currentUser.userId).setData(
            [
                "userId": currentUser.userId,
                sendedlikesUpdateFiled: FieldValue.arrayUnion([myLikeUserDic])
            ], merge: true) { error in
                if let error = error {
                    print("평가 업데이트 에러: \(error)")
                }
            }
        docRef.document(receiveUserInfo.id).setData(
            [
                "userId": receiveUserInfo.id,
                recivedlikesUpdateFiled: FieldValue.arrayUnion([myInfoDic])
            ], merge: true) { error in
                if let error = error {
                    print("평가 업데이트 에러: \(error)")
                }
            }
    }
    
    func deleteLikeData() {
        if let myData = HomeUserCardViewModel.passedMyData.last,
           let userData = HomeUserCardViewModel.passedUserData.last,
           let userId = myData["likedUserId"] as? String {
            docRef.document(currentUser.userId).updateData(
                [
                    sendedlikesUpdateFiled: FieldValue.arrayRemove([myData])
                ]) { error in
                    if let error = error {
                        print("삭제 my 에러: \(error)")
                    } else {
                        HomeUserCardViewModel.passedMyData.removeLast()
                    }
                }
            
            docRef.document(userId).updateData(
                [
                    recivedlikesUpdateFiled: FieldValue.arrayRemove([userData])
                ]) { error in
                    if let error = error {
                        print("삭제 user 에러: \(error)")
                    } else {
                        HomeUserCardViewModel.passedUserData.removeLast()
                    }
                }
        } else {
            print("삭제할 데이터가 없습니다.")
        }
    }
    
    func purchaseChu(chu: Int) {
        FirestoreService.shared.updateDocument(collectionId: .users, documentId: currentUser.userId, field: "chuCount", data: self.currentChuCount - chu, completion: { _ in
            UserDefaultsManager.shared.updateChuCount(self.currentChuCount - chu)
            let payment: Payment = Payment(price: chu * 110, purchaseChuCount: -chu)
            FirestoreService.shared.saveDocument(collectionId: .payment, documentId: self.currentUser.userId, fieldId: "purchases", data: payment) { _ in
                print("남은 츄 \(UserDefaultsManager.shared.getChuCount())")
            }
        })
    }
}
