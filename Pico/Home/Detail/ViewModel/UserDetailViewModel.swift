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

final class UserDetailViewModel {
    let userObservable = PublishSubject<User>()
    private let disposeBag = DisposeBag()
    private let dbRef = Firestore.firestore().collection(Collections.users.name)
    private let loginUser = UserDefaultsManager.shared.getUserData()
    private let sendedlikesUpdateFiled = "sendedlikes"
    private let recivedlikesUpdateFiled = "recivedlikes"
    
    init(user: User) {
        loadUser(user: user)
    }
    
    // 유저 불러오기
    func loadUser(user: User) {
        FirestoreService.shared.loadDocumentRx(collectionId: .users, documentId: user.id, dataType: User.self)
            .compactMap { $0 }
            .bind(to: userObservable)
            .disposed(by: disposeBag)
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
