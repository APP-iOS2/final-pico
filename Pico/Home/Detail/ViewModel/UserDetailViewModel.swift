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
    private let myID = UserDefaultsManager.shared.getUserData().userId
    
    init(user: User) {
         loadUser(user: user)
    }
    
    func loadUser(user: User) {
        FirestoreService.shared.loadDocumentRx(collectionId: .users, documentId: user.id, dataType: User.self)
            .compactMap { $0 }
            .bind(to: userObservable)
            .disposed(by: disposeBag)
    }
    
    // document 에 들어가는 ID만 수정
    func reportUser(report: Report, completion: @escaping () -> () ) {
        DispatchQueue.global().async {
            self.dbRef.document("\(report.reportedId)").updateData([
                "reports": FieldValue.arrayUnion([report.asDictionary()])
            ])
            print("Success to save new document at users \(report.reportedId)")
        }
        completion()
    }
    
    func blockUser(block: Block, completion: @escaping () -> () ) {
        DispatchQueue.global().async {
            self.dbRef.document(self.myID).updateData([
                // document("내 아이디") Blocks[상대방 정보]
                "blocks": FieldValue.arrayUnion([block.asDictionary()])
            ])
            print("Success to save new document at users \(block)")
        }
        completion()
    }
    
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
