//
//  MailViewModel.swift
//  Pico
//
//  Created by 양성혜 on 2023/10/05.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import FirebaseFirestore
import FirebaseFirestoreSwift

enum MailType: String {
    case send = "보낸 쪽지"
    case receive = "받은 쪽지"
}

struct DummyMailUsers {
    let userName: String
    let age: Int
    let mbti: MBTIType
    let mailType: MailType
    let messages: DummyMail
    var title: String {
        return "\(userName), \(age)"
    }
}

struct DummyMail {
    let oppenentName: String
    let oppenentAge: Int
    let imageUrl: String
    let mbti: MBTIType
    let message: String
    let sendedDate: String
    let isReading: Bool
    var oppenentTitle: String {
        return "\(oppenentName), \(oppenentAge)"
    }
}

final class MailViewModel {
    
    var mailList = BehaviorRelay<[DummyMailUsers]>(value: [])
    var mailSendList = BehaviorRelay<[DummyMailUsers]>(value: [])
    var mailRecieveList = BehaviorRelay<[DummyMailUsers]>(value: [])
    
    var mailIsEmpty: Observable<Bool> {
        return mailList
            .map { $0.isEmpty }
    }
    
    init() {
        let mail: [DummyMailUsers] = [
            DummyMailUsers(userName: "오점순", age: 26, mbti: .enfj, mailType: .receive, messages:
                            DummyMail(oppenentName: "스윗라임", oppenentAge: 28, imageUrl: "https://cdn.topstarnews.net/news/photo/201906/636333_333283_461.jpg", mbti: .enfp, message: "날이 요즘 너무 쌀쌀해", sendedDate: "09.24", isReading: false)),
            DummyMailUsers(userName: "오점순", age: 26, mbti: .enfj, mailType: .send, messages:
                            DummyMail(oppenentName: "스윗라임", oppenentAge: 24, imageUrl: "https://cdn.topstarnews.net/news/photo/201906/636333_333283_461.jpg", mbti: .entj, message: "오늘 날이 참 좋다", sendedDate: "10.24", isReading: true)),
            DummyMailUsers(userName: "오점순", age: 26, mbti: .enfj, mailType: .receive, messages:
                            DummyMail(oppenentName: "멍때리는댕댕이구름", oppenentAge: 24, imageUrl: "https://image5jvqbd.fmkorea.com/files/attach/new2/20211225/3655109/3113058505/4195166827/e130faca7194985e4f162b3583d52853.jpg", mbti: .infj, message: "점순아 반가워 \n점심으로 뭘 먹었니?", sendedDate: "10.24", isReading: false)),
            DummyMailUsers(userName: "오점순", age: 26, mbti: .enfj, mailType: .send, messages:
                            DummyMail(oppenentName: "멍때리는댕댕이구름", oppenentAge: 24, imageUrl: "https://image5jvqbd.fmkorea.com/files/attach/new2/20211225/3655109/3113058505/4195166827/e130faca7194985e4f162b3583d52853.jpg", mbti: .istj, message: "일상에 미소를 채우는 더 좋은 한입", sendedDate: "10.24", isReading: true)),
            DummyMailUsers(userName: "오점순", age: 26, mbti: .enfj, mailType: .receive, messages:
                            DummyMail(oppenentName: "마이꾸미", oppenentAge: 24, imageUrl: "https://cdn.newsculture.press/news/photo/202306/526271_651222_532.jpg", mbti: .esfp, message: "한달뒤에 보자", sendedDate: "08.11", isReading: true))
        ]
        mailList.accept(mail)
        divideMail()
    }
    
    private func divideMail() {
        var receiveMails: [DummyMailUsers] = []
        var sendMails: [DummyMailUsers] = []
        
        _ = mailList.value
            .map {
                if $0.mailType == .receive {
                    receiveMails.append($0)
                } else {
                    sendMails.append($0)
                }
            }
        mailSendList.accept(sendMails)
        mailRecieveList.accept(receiveMails)
    }
    
    func saveMailData(sendUserInfo: User, receiveUserInfo: User, message: String) {
        
        let dbRef = Firestore.firestore().collection(Collections.mail.name)
        /*
         firestore.saveDocument(collectionId: .mail,
         documentId: UUID().uuidString,
         data: Mail(userId: UUID().uuidString,
         mailInfo: [Mail.MailInfo(id: UUID().uuidString, sendedUserId: UUID().uuidString, receivedUserId: UUID().uuidString, messages: [Mail.Message(id: UUID().uuidString, message: messageView.text, sendedDate: dateFormetter())])]) )
         */
        
        let messages: [String: Any] = [
            "messageId": UUID().uuidString,
            "message": message,
            "sendedDate": Date().timeIntervalSince1970.toString()
        ]
        
        // 보내는 사람
        dbRef.document(sendUserInfo.id).setData(
            [
                "userId": sendUserInfo.id,
                "mailInfo": [
                    "sendedUserId": sendUserInfo.id,
                    "receivedUserId": receiveUserInfo.id,
                    "messages": FieldValue.arrayUnion([messages])
                ]
            ], merge: true) { error in
                if let error = error {
                    print("평가 업데이트 에러: \(error)")
                } else {
                    print("평가 업데이트 성공")
                }
            }
        
        // 받는 사람
        dbRef.document(receiveUserInfo.id).setData(
            [
                "userId": receiveUserInfo.id,
                "mailInfo": [
                    "sendedUserId": sendUserInfo.id,
                    "receivedUserId": receiveUserInfo.id,
                    "messages": FieldValue.arrayUnion([messages])
                ]
            ], merge: true) { error in
                if let error = error {
                    print("평가 업데이트 에러: \(error)")
                } else {
                    print("평가 업데이트 성공")
                }
            }
    }
}
