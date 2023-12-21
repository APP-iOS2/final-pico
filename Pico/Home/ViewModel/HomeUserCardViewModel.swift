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
    private var partnerSendedLikeData: Like.LikeInfo = Like.likeInfoSample
    static var passedMyData: [[String: Any]] = []
    static var passedUserData: [[String: Any]] = []
    static var cardCounting: Int = 0
    
    func notificationServiceForPartner(_ pushType: PushNotiType, _ notiType: NotiType, user: User, currentUser: CurrentUser) {
        NotificationService.shared.sendNotification(userId: user.id, sendUserName: currentUser.nickName, notiType: pushType)
        guard let myMbti = MBTIType(rawValue: currentUser.mbti) else { return }
        let noti = Noti(receiveId: user.id, sendId: currentUser.userId, name: currentUser.nickName, birth: currentUser.birth, imageUrl: currentUser.imageURL, notiType: notiType, mbti: myMbti, createDate: Date().timeIntervalSince1970)
        FirestoreService.shared.saveDocument(collectionId: .notifications, data: noti)
    }
    
    func notificationServiceForMe(_ pushType: PushNotiType, _ notiType: NotiType, user: User, currentUser: CurrentUser) {
        NotificationService.shared.sendNotification(userId: currentUser.userId, sendUserName: user.nickName, notiType: pushType)
        guard let myMbti = MBTIType(rawValue: user.mbti.rawValue) else { return }
        let noti = Noti(receiveId: currentUser.userId, sendId: user.id, name: user.nickName, birth: user.birth, imageUrl: user.imageURLs[safe: 0] ?? "", notiType: notiType, mbti: myMbti, createDate: Date().timeIntervalSince1970)
        FirestoreService.shared.saveDocument(collectionId: .notifications, data: noti)
    }
    
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
        if likeType == .matching {
            docRef.document(receiveUserInfo.id).setData(
                [
                    "userId": receiveUserInfo.id,
                    sendedlikesUpdateFiled: FieldValue.arrayUnion([myInfoDic])
                ], merge: true) { error in
                    if let error = error {
                        print("평가 업데이트 에러: \(error)")
                    }
                }
        } else {
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
    
    func updateMatcingData(_ userId: String) {
        docRef.document(userId).updateData(
            [
                sendedlikesUpdateFiled: FieldValue.arrayRemove([partnerSendedLikeData.asDictionary()])
            ]) { error in
                if let error = error {
                    print("삭제 my 에러: \(error)")
                }
            }
        
        DispatchQueue.global().async { [self] in
            docRef.document(currentUser.userId).getDocument { [self] (document, error) in
                if let error = error {
                    print("에러 : \(error)")
                } else if let document = document, document.exists {
                    if let data = try? document.data(as: Like.self), var recivedlikes = data.recivedlikes {
                        recivedlikes.removeAll { $0.likedUserId == userId }
                        let recivedlikesDictArray = recivedlikes.map { $0.asDictionary() }
                        docRef.document(currentUser.userId).updateData(
                            [
                                "recivedlikes": recivedlikesDictArray
                            ]) { error in
                                if let error = error {
                                    print("에러 : \(error)")
                                } else {
                                    print("매칭 문서 업데이트 성공")
                                }
                            }
                    }
                } else {
                    print("해당 문서가 존재하지 않습니다.")
                }
            }
        }
    }
    
    func purchaseChu(currentChu: Int, purchaseChu: Int) {
        FirestoreService.shared.updateDocument(collectionId: .users, documentId: currentUser.userId, field: "chuCount", data: currentChu - purchaseChu, completion: { _ in
            UserDefaultsManager.shared.updateChuCount(currentChu - purchaseChu)
            let payment: Payment.PaymentInfo = Payment.PaymentInfo(price: 0, purchaseChuCount: -purchaseChu, paymentType: .backCard)
            FirestoreService.shared.saveDocument(collectionId: .payment, documentId: self.currentUser.userId, fieldId: "paymentInfos", data: payment) { _ in
                print("남은 츄 \(UserDefaultsManager.shared.getChuCount())")
            }
        })
    }
    
    func checkYouLikeMe(_ partnerId: String, _ myId: String, completion: @escaping (Like.LikeInfo?) -> Void) {
        var result: Like.LikeInfo?
        let dbRef = Firestore.firestore().collection(Collections.likes.name)
        
        DispatchQueue.global().async {
            dbRef.document(partnerId).getDocument { [self] (document, error) in
                if let error = error {
                    print("Error getting document: \(error)")
                    completion(nil)
                    
                } else if let document = document, document.exists {
                    if let data = try? document.data(as: Like.self), let sendedLikes = data.sendedlikes {
                        let sendedLikesData: [Like.LikeInfo] = sendedLikes
                        for data in sendedLikesData where data.likedUserId == myId {
                            partnerSendedLikeData = data
                            result = partnerSendedLikeData
                        }
                    }
                    completion(result)
                    
                } else {
                    print("해당 문서가 존재하지 않습니다.")
                    completion(nil)
                }
            }
        }
    }
}
