//
//  UserDetailViewModel.swift
//  Pico
//
//  Created by 신희권 on 2023/09/27.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import RxSwift
import RxRelay
import CoreLocation

final class UserDetailViewModel {
    let user: User!
    let compatibilityView: CompatibilityView
    var isHome = false
    private let disposeBag = DisposeBag()
    private let dbRef = Firestore.firestore().collection(Collections.users.name)
    private let loginUser = UserDefaultsManager.shared.getUserData()
    private let sendedlikesUpdateFiled = "sendedlikes"
    private let recivedlikesUpdateFiled = "recivedlikes"
    private let currentUser = UserDefaultsManager.shared.getUserData()
    private var partnerSendedLikeData: Like.LikeInfo = Like.likeInfoSample
    
    init(user: User, isHome: Bool) {
        var user = user
        if isHome {
            user.imageURLs.remove(at: 1)
            self.isHome = true
        }
        self.user = user
        compatibilityView = CompatibilityView(currentUser: loginUser, cardUser: user)
    }
    
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
    
    func checkYouLikeMe(_ partnerId: String, _ myId: String, completion: @escaping (Like.LikeType?) -> Void) {
        var result: Like.LikeType = .dislike
        let dbRef = Firestore.firestore().collection("likes")
        
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
                            if data.likeType == .like {
                                result = .like
                            }
                            if data.likeType == .matching {
                                result = .matching
                            }
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
    
    func updateMatcingData(_ userId: String) {
        let docRef = Firestore.firestore().collection(Collections.likes.name)
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
    
    // 거리
    func calculateDistance() -> CLLocationDistance {
        let currentUserLoc = CLLocation(latitude: loginUser.latitude, longitude: loginUser.longitude)
        let otherUserLoc = CLLocation(latitude: user.location.latitude, longitude: user.location.longitude)
        return  currentUserLoc.distance(from: otherUserLoc)
    }
    
    // like 판단
    func isLike( completion: @escaping (Bool) -> ()) {
        var isLiked = false
        let ref = Firestore.firestore().collection(Collections.likes.name).document(loginUser.userId)
        ref.getDocument { [weak self] document, error in
            guard let self = self else { return }
            if let error = error {
                print(error)
            }
            if let document = document, document.exists {
                if let datas = try? document.data(as: Like.self).sendedlikes?.filter({ like in
                    like.likedUserId == self.user.id
                }) {
                    isLiked = datas.isEmpty ? false : true
                } else {
                    print("문서를 찾을 수 없습니다.")
                }
            }
            completion(isLiked)
        }
    }
        // 신고
        func reportUser(reportedUser: User, reason: String, completion: @escaping () -> ()) {
            DispatchQueue.global().async {
                let sendReportInfo: Report.ReportInfo = Report.ReportInfo(reportedUserId: reportedUser.id,
                                                                          reason: reason,
                                                                          birth: reportedUser.birth,
                                                                          nickName: reportedUser.nickName,
                                                                          mbti: reportedUser.mbti,
                                                                          imageURL: reportedUser.imageURLs[0],
                                                                          createdDate: Date().timeIntervalSince1970)
                
                let recivedReportInfo: Report.ReportInfo = Report.ReportInfo(reportedUserId: self.loginUser.userId,
                                                                             reason: reason,
                                                                             birth: self.loginUser.birth,
                                                                             nickName: self.loginUser.nickName,
                                                                             mbti: MBTIType(rawValue: self.loginUser.mbti) ?? .enfj,
                                                                             imageURL: self.loginUser.imageURL,
                                                                             createdDate: Date().timeIntervalSince1970)
                
                // sendReport (신고한 사람)
                self.dbRef.document(self.loginUser.userId)
                    .collection("Report")
                    .document(self.loginUser.userId)
                    .setData([
                        "sendReport": FieldValue.arrayUnion([sendReportInfo.asDictionary()])
                    ], merge: true) { error in
                        if let error = error {
                            print("신고 업데이트 에러: \(error)")
                        } else {
                            print("Success to save new document at SendReport \(sendReportInfo)")
                        }
                    }
                
                // RecivedReport (신고당한 사람)
                self.dbRef.document(reportedUser.id)
                    .collection("Report")
                    .document(reportedUser.id)
                    .setData([
                        "recivedReport": FieldValue.arrayUnion([recivedReportInfo.asDictionary()])
                    ], merge: true) { error in
                        if let error = error {
                            print("신고 업데이트 에러: \(error)")
                        } else {
                            print("Success to save new document at RecivedReport \(recivedReportInfo)")
                        }
                    }
            }
            completion()
        }
        
        // 차단
        func blockUser(blockedUser: User, completion: @escaping () -> ()) {
            DispatchQueue.global().async {
                let sendBlockInfo = Block.BlockInfo(userId: blockedUser.id,
                                                    birth: blockedUser.birth,
                                                    nickName: blockedUser.nickName,
                                                    mbti: blockedUser.mbti,
                                                    imageURL: blockedUser.imageURLs[0],
                                                    createdDate: Date().timeIntervalSince1970)
                
                let recivedBlockInfo = Block.BlockInfo(userId: self.loginUser.userId,
                                                       birth: self.loginUser.birth,
                                                       nickName: self.loginUser.nickName,
                                                       mbti: MBTIType(rawValue: self.loginUser.mbti) ?? .enfj,
                                                       imageURL: self.loginUser.imageURL,
                                                       createdDate: Date().timeIntervalSince1970)
                
                // SendBlock (내가 차단한 사람)
                self.dbRef.document(self.loginUser.userId)
                    .collection("Block")
                    .document(self.loginUser.userId)
                    .setData([
                        "sendBlock": FieldValue.arrayUnion([sendBlockInfo.asDictionary()])
                    ], merge: true) { error in
                        if let error = error {
                            print("블록 업데이트 에러: \(error)")
                        } else {
                            print("Success to save new document at sendBlock \(sendBlockInfo)")
                        }
                    }
                
                // RecivedBlock (누구에게 차단 당했는지)
                self.dbRef.document(blockedUser.id)
                    .collection("Block")
                    .document(blockedUser.id)
                    .setData([
                        "recivedBlock": FieldValue.arrayUnion([recivedBlockInfo.asDictionary()])
                    ], merge: true) { error in
                        if let error = error {
                            print("블록 업데이트 에러: \(error)")
                        } else {
                            print("Success to save new document at sendBlock \(recivedBlockInfo)")
                        }
                    }
            }
            completion()
        }
        
        // Like 클릭시 저장 함수
        func saveLikeData(receiveUserInfo: User, likeType: Like.LikeType) {
            let docRef = Firestore.firestore().collection(Collections.likes.name)
            let myLikeUser: Like.LikeInfo = Like.LikeInfo(likedUserId: receiveUserInfo.id,
                                                          likeType: likeType,
                                                          birth: receiveUserInfo.birth,
                                                          nickName: receiveUserInfo.nickName,
                                                          mbti: receiveUserInfo.mbti,
                                                          imageURL: receiveUserInfo.imageURLs[0],
                                                          createdDate: Date().timeIntervalSince1970)
            let myLikeUserDic = myLikeUser.asDictionary()
            let myInfo: Like.LikeInfo = Like.LikeInfo(likedUserId: loginUser.userId,
                                                      likeType: likeType,
                                                      birth: loginUser.birth,
                                                      nickName: loginUser.nickName,
                                                      mbti: MBTIType(rawValue: loginUser.mbti) ?? .entp,
                                                      imageURL: loginUser.imageURL,
                                                      createdDate: Date().timeIntervalSince1970)
            let myInfoDic = myInfo.asDictionary()
            HomeUserCardViewModel.passedMyData.append(myLikeUserDic)
            HomeUserCardViewModel.passedUserData.append(myInfoDic)
            
            docRef.document(loginUser.userId).setData(
                [
                    "userId": loginUser.userId,
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
    }
