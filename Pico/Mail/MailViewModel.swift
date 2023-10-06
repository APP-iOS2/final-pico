//
//  MailViewModel.swift
//  Pico
//
//  Created by 양성혜 on 2023/10/05.
//

import UIKit
import RxSwift
import RxRelay

enum MailType {
    case send
    case receive
}

struct DummyMailUsers {
    let userName: String
    let age: String
    let mbti: MBTIType
    let mailType: MailType
    let messages: DummyMail
    var title: String {
        return "\(userName), \(age)"
    }
}

struct DummyMail {
    let oppenentName: String
    let oppenentAge: String
    let imageUrl: String
    let mbti: MBTIType
    let message: String
    let sendedDate: String
    var oppenentTitle: String {
        return "\(oppenentName), \(oppenentAge)"
    }
}

final class MailViewModel {
    var mailList = BehaviorRelay<[DummyMailUsers]>(value: [])
    var mailIsEmpty: Observable<Bool> {
            return mailList
                .map { $0.isEmpty }
                .distinctUntilChanged()
        }
    
    init() {
        let mail: [DummyMailUsers] = [
            DummyMailUsers(userName: "오점순", age: "991122", mbti: .enfj, mailType: .receive, messages:
                            DummyMail(oppenentName: "스윗라임", oppenentAge: "981212", imageUrl: "https://cdn.topstarnews.net/news/photo/201906/636333_333283_461.jpg", mbti: .enfp, message: "날이 요즘 너무 쌀쌀해", sendedDate: "2023.09.24")),
            DummyMailUsers(userName: "오점순", age: "991122", mbti: .enfj, mailType: .receive, messages:
                            DummyMail(oppenentName: "멍때리는댕댕이구름", oppenentAge: "010101", imageUrl: "https://image5jvqbd.fmkorea.com/files/attach/new2/20211225/3655109/3113058505/4195166827/e130faca7194985e4f162b3583d52853.jpg", mbti: .intj, message: "점순아 반가워 \t점심으로 뭘 먹었니?", sendedDate: "2023.10.24")),
            DummyMailUsers(userName: "오점순", age: "991122", mbti: .enfj, mailType: .receive, messages:
                            DummyMail(oppenentName: "마이꾸미", oppenentAge: "000411", imageUrl: "https://cdn.newsculture.press/news/photo/202306/526271_651222_532.jpg", mbti: .esfp, message: "한달뒤에 보자", sendedDate: "23.08.11"))
            ]
        
        mailList.accept(mail)
    }
}
