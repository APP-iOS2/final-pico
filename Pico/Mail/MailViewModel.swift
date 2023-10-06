//
//  MailViewModel.swift
//  Pico
//
//  Created by 양성혜 on 2023/10/05.
//

import UIKit
import RxSwift
import RxRelay

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
                            DummyMail(oppenentName: "스윗라임", oppenentAge: 24, imageUrl: "https://cdn.topstarnews.net/news/photo/201906/636333_333283_461.jpg", mbti: .intj, message: "오늘 날이 참 좋다", sendedDate: "10.24", isReading: true)),
            DummyMailUsers(userName: "오점순", age: 26, mbti: .enfj, mailType: .receive, messages:
                            DummyMail(oppenentName: "멍때리는댕댕이구름", oppenentAge: 24, imageUrl: "https://image5jvqbd.fmkorea.com/files/attach/new2/20211225/3655109/3113058505/4195166827/e130faca7194985e4f162b3583d52853.jpg", mbti: .intj, message: "점순아 반가워 \n점심으로 뭘 먹었니?", sendedDate: "10.24", isReading: false)),
            DummyMailUsers(userName: "오점순", age: 26, mbti: .enfj, mailType: .send, messages:
                            DummyMail(oppenentName: "멍때리는댕댕이구름", oppenentAge: 24, imageUrl: "https://image5jvqbd.fmkorea.com/files/attach/new2/20211225/3655109/3113058505/4195166827/e130faca7194985e4f162b3583d52853.jpg", mbti: .intj, message: "일상에 미소를 채우는 더 좋은 한입", sendedDate: "10.24", isReading: true)),
            DummyMailUsers(userName: "오점순", age: 26, mbti: .enfj, mailType: .receive, messages:
                            DummyMail(oppenentName: "마이꾸미", oppenentAge: 24, imageUrl: "https://cdn.newsculture.press/news/photo/202306/526271_651222_532.jpg", mbti: .esfp, message: "한달뒤에 보자", sendedDate: "08.11", isReading: true))
            ]
        mailList.accept(mail)
        divideMail()
    }
    
    func divideMail() {
        
        var receiveMails: [DummyMailUsers] = []
        var sendMails: [DummyMailUsers] = []
        
        mailList.value
            .map {
                if $0.mailType == .receive {
                    receiveMails.append($0)
                } else {
                    sendMails.append($0)
                }
            }
        mailSendList.accept(sendMails)
        mailRecieveList.accept(receiveMails)
        
        print("sendData")
        print(sendMails)
        
        print("----------")
        print("receive")
        print(receiveMails)
    }
}
