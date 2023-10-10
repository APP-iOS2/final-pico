//
//  HomeUserCardViewModel.swift
//  Pico
//
//  Created by 임대진 on 10/5/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// 평가 보낼때 문서 Id가 userId인 문서 안에 userId 와 sendedlikes 저장하고,
// 문서 Id가 상대방 id인 문서에 userId 와 recivedlikes 저장
// 되돌리기 누르면 직전에 보낸 문서 내용삭제 -> 여러번가능
// 친구 추천 받을때 내 문서안에 내가 좋아요한 사람 빼고 불러오기

final class HomeUserCardViewModel {
    let tempMy = User(id: "조인성", mbti: .enfj, phoneNumber: "01099998888", gender: .male, birth: "960917", nickName: "인성보소", location: Location(address: "한국", latitude: 1, longitude: 1), imageURLs: ["https://i.namu.wiki/i/HJ5Ue56pWsvoy0bUBJpybjMOBQDWlbRcBRtwfM_CbeOQc60x7nTFBJaux2yRyuFKz64ioVYUvP6ij-Q5ipRQTg.webp"], createdDate: 1.1, subInfo: nil, reports: nil, blocks: nil, chuCount: 0, isSubscribe: false)
    
    func saveLikeData(sendUserInfo: User, receiveUserInfo: User, likeType: Like.LikeType) {
        // 코더블로 하려했는데 배열필드에 append하는게 데이터 변환해서 알아서 안들어가서 수기로 넣었어요 ㅠ
        
        let dbRef = Firestore.firestore()
        
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
        
        let sendedlikesUpdateFiled = "sendedlikes"
        let recivedlikesUpdateFiled = "recivedlikes"
        
        let docRef = dbRef.collection(Collections.likes.name)
        
        docRef.document(sendUserInfo.id).setData(
            [
                "userId": sendUserInfo.id,
                sendedlikesUpdateFiled: FieldValue.arrayUnion([myLikeUser])
            ], merge: true) { error in
                if let error = error {
                    print("평가 업데이트 에러: \(error)")
                } else {
                    print("평가 업데이트 성공")
                }
            }
        docRef.document(receiveUserInfo.id).setData(
            [
                "userId": receiveUserInfo.id,
                recivedlikesUpdateFiled: FieldValue.arrayUnion([myInfo])
            ], merge: true) { error in
                if let error = error {
                    print("평가 업데이트 에러: \(error)")
                } else {
                    print("평가 업데이트 성공")
                }
            }
    }
}
