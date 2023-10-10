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
    let tempMy = User(id: "조인성", mbti: .enfj, phoneNumber: "01099998888", gender: .male, birth: "1996-09-17", nickName: "인성보소", location: Location(address: "한국", latitude: 1, longitude: 1), imageURLs: ["https://i.namu.wiki/i/HJ5Ue56pWsvoy0bUBJpybjMOBQDWlbRcBRtwfM_CbeOQc60x7nTFBJaux2yRyuFKz64ioVYUvP6ij-Q5ipRQTg.webp"], createdDate: 1.1, subInfo: nil, reports: nil, blocks: nil, chuCount: 0, isSubscribe: false)
    private let sendedlikesUpdateFiled = "sendedlikes"
    private let recivedlikesUpdateFiled = "recivedlikes"
    private let docRef = Firestore.firestore().collection(Collections.likes.name)
    static var passedMyData: [[String: Any]] = []
    static var passedUserData: [[String: Any]] = []
    
    func saveLikeData(sendUserInfo: User, receiveUserInfo: User, likeType: Like.LikeType) {
        // 코더블로 하려했는데 배열필드에 append하는게 데이터 변환해서 알아서 안들어가서 수기로 넣었어요 ㅠ
        
        let myLikeUser: [String: Any] = [
            "likedUserId": receiveUserInfo.id,
            "likeType": likeType.rawValue,
            "birth": receiveUserInfo.birth,
            "nickName": receiveUserInfo.nickName,
            "mbti": receiveUserInfo.mbti.rawValue,
            "imageURL": receiveUserInfo.imageURLs[0]
        ]
        let myInfo: [String: Any] = [
            "likedUserId": sendUserInfo.id,
            "likeType": likeType.rawValue,
            "birth": sendUserInfo.birth,
            "nickName": sendUserInfo.nickName,
            "mbti": sendUserInfo.mbti.rawValue,
            "imageURL": sendUserInfo.imageURLs[0]
        ]
        HomeUserCardViewModel.passedMyData.append(myLikeUser)
        HomeUserCardViewModel.passedUserData.append(myInfo)
        
        docRef.document(sendUserInfo.id).setData(
            [
                "userId": sendUserInfo.id,
                sendedlikesUpdateFiled: FieldValue.arrayUnion([myLikeUser])
            ], merge: true) { error in
                if let error = error {
                    print("평가 업데이트 에러: \(error)")
                }
            }
        docRef.document(receiveUserInfo.id).setData(
            [
                "userId": receiveUserInfo.id,
                recivedlikesUpdateFiled: FieldValue.arrayUnion([myInfo])
            ], merge: true) { error in
                if let error = error {
                    print("평가 업데이트 에러: \(error)")
                }
            }
    }
    
    func deleteLikeData(sendUserInfo: User) {
        if let myData = HomeUserCardViewModel.passedMyData.last,
           let userData = HomeUserCardViewModel.passedUserData.last,
           let userId = myData["likedUserId"] as? String {
            docRef.document(sendUserInfo.id).updateData(
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

}
