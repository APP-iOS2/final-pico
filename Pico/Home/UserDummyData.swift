//
//  UserDummyData.swift
//  Pico
//
//  Created by 임대진 on 10/4/23.
//

import Foundation

struct UserDummyData {
    static let users: [User] = {
        let user1 = User(mbti: .enfp, phoneNumber: "01012341234", gender: .female, birth: "960917", nickName: "지젤", location: Location(address: "서울시 강남구", latitude: 10, longitude: 10), imageURLs: [
            "https://mblogthumb-phinf.pstatic.net/MjAyMjAxMDNfMTg2/MDAxNjQxMjEyOTI2NDc4.KruADoj55vedTCQY5gA2tdWoKckKh8WdhoPlvAs9Mnsg.lRDzpNkVASBeAAX-MFROpCB6Q_9Lkc6AQcz7vZ5u_Vwg.JPEG.ssun2415/IMG_8432.jpg?type=w800",
            "https://image5jvqbd.fmkorea.com/files/attach/new2/20211225/3655109/3113058505/4195166827/e130faca7194985e4f162b3583d52853.jpg",
            "https://img.dmitory.com/img/202107/2lh/a8H/2lha8HnRr6Q046GGGQ0uwM.jpg",
            "https://pbs.twimg.com/media/FJtITDWXwAUQB3y.jpg:large",
            "https://img.dmitory.com/img/202107/2lh/a8H/2lha8HnRr6Q046GGGQ0uwM.jpg"], createdDate: 10, subInfo: nil, reports: nil, blocks: nil, chuCount: 0, isSubscribe: false)
        let user2 = User(mbti: .infp, phoneNumber: "01012341234", gender: .female, birth: "970917", nickName: "닝닝", location: Location(address: "서울시 강남구", latitude: 10, longitude: 10), imageURLs: [
            "https://pbs.twimg.com/media/FJtITDWXwAUQB3y.jpg:large",
            "https://img.dmitory.com/img/202107/2lh/a8H/2lha8HnRr6Q046GGGQ0uwM.jpg",
            "https://mblogthumb-phinf.pstatic.net/MjAyMjAxMDNfMTg2/MDAxNjQxMjEyOTI2NDc4.KruADoj55vedTCQY5gA2tdWoKckKh8WdhoPlvAs9Mnsg.lRDzpNkVASBeAAX-MFROpCB6Q_9Lkc6AQcz7vZ5u_Vwg.JPEG.ssun2415/IMG_8432.jpg?type=w800",
            "https://image5jvqbd.fmkorea.com/files/attach/new2/20211225/3655109/3113058505/4195166827/e130faca7194985e4f162b3583d52853.jpg",
            "https://img.dmitory.com/img/202107/2lh/a8H/2lha8HnRr6Q046GGGQ0uwM.jpg"], createdDate: 10, subInfo: nil, reports: nil, blocks: nil, chuCount: 0, isSubscribe: false)
        let user3 = User(mbti: .estj, phoneNumber: "01012341234", gender: .female, birth: "980917", nickName: "카리나", location: Location(address: "서울시 강남구", latitude: 10, longitude: 10), imageURLs: [
            "https://img.dmitory.com/img/202107/2lh/a8H/2lha8HnRr6Q046GGGQ0uwM.jpg",
            "https://mblogthumb-phinf.pstatic.net/MjAyMjAxMDNfMTg2/MDAxNjQxMjEyOTI2NDc4.KruADoj55vedTCQY5gA2tdWoKckKh8WdhoPlvAs9Mnsg.lRDzpNkVASBeAAX-MFROpCB6Q_9Lkc6AQcz7vZ5u_Vwg.JPEG.ssun2415/IMG_8432.jpg?type=w800",
            "https://image5jvqbd.fmkorea.com/files/attach/new2/20211225/3655109/3113058505/4195166827/e130faca7194985e4f162b3583d52853.jpg",
            "https://img.dmitory.com/img/202107/2lh/a8H/2lha8HnRr6Q046GGGQ0uwM.jpg",
            "https://pbs.twimg.com/media/FJtITDWXwAUQB3y.jpg:large"], createdDate: 10, subInfo: nil, reports: nil, blocks: nil, chuCount: 0, isSubscribe: false)
        let user4 = User(mbti: .istj, phoneNumber: "01012341234", gender: .female, birth: "990917", nickName: "원터", location: Location(address: "서울시 강남구", latitude: 10, longitude: 10), imageURLs: [
            "https://image5jvqbd.fmkorea.com/files/attach/new2/20211225/3655109/3113058505/4195166827/e130faca7194985e4f162b3583d52853.jpg",
            "https://img.dmitory.com/img/202107/2lh/a8H/2lha8HnRr6Q046GGGQ0uwM.jpg",
            "https://pbs.twimg.com/media/FJtITDWXwAUQB3y.jpg:large",
            "https://img.dmitory.com/img/202107/2lh/a8H/2lha8HnRr6Q046GGGQ0uwM.jpg",
            "https://mblogthumb-phinf.pstatic.net/MjAyMjAxMDNfMTg2/MDAxNjQxMjEyOTI2NDc4.KruADoj55vedTCQY5gA2tdWoKckKh8WdhoPlvAs9Mnsg.lRDzpNkVASBeAAX-MFROpCB6Q_9Lkc6AQcz7vZ5u_Vwg.JPEG.ssun2415/IMG_8432.jpg?type=w800"], createdDate: 10, subInfo: nil, reports: nil, blocks: nil, chuCount: 0, isSubscribe: false)
        return [user1, user2, user3, user4]
    }()
}