//
//  NotificationViewModel.swift
//  Pico
//
//  Created by 방유빈 on 2023/10/04.
//

import Foundation
import RxSwift
import RxRelay

struct DummyNoti {
    let name: String
    let age: Int
    let imageUrl: String
    let notiType: NotiType
    var title: String {
        return "\(name), \(age)"
    }
}

final class NotificationViewModel {
    var notifications = BehaviorRelay<[DummyNoti]>(value: [])
    
    init() {
        let noti: [DummyNoti] = [
            DummyNoti(name: "찐 윈터", age: 21, imageUrl: "https://image5jvqbd.fmkorea.com/files/attach/new2/20211225/3655109/3113058505/4195166827/e130faca7194985e4f162b3583d52853.jpg", notiType: .like),
            DummyNoti(name: "찐 윈터라니깐여;", age: 21, imageUrl: "https://image5jvqbd.fmkorea.com/files/attach/new2/20211225/3655109/3113058505/4195166827/e130faca7194985e4f162b3583d52853.jpg", notiType: .message),
            DummyNoti(name: "풍리나", age: 35, imageUrl: "https://flexible.img.hani.co.kr/flexible/normal/640/441/imgdb/original/2023/0525/20230525501996.jpg", notiType: .like)
        ]
        
        notifications.accept(noti)
    }
}
