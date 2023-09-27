//
//  UserDummy.swift
//  Pico
//
//  Created by 오영석 on 2023/09/27.
//

import Foundation

struct DummyUserData {
    static let users: [User] = {
        let user1 = User(
            mbti: .enfp,
            phoneNumber: "01012345678",
            gender: .male,
            birth: "0101",
            nickName: "냥냥펀치",
            location: Location(address: "주소", latitude: 0.0, longitude: 0.0),
            imageURLs: [],
            createdDate: Date().timeIntervalSince1970,
            subInfo: DummySubInfo.subInfo,
            reports: nil,
            blocks: nil,
            chuCount: 100,
            isSubscribe: true
        )
        
        let user2 = User(
            mbti: .infp,
            phoneNumber: "01023456789",
            gender: .female,
            birth: "0202",
            nickName: "오로치마루",
            location: Location(address: "주소", latitude: 0.0, longitude: 0.0),
            imageURLs: [],
            createdDate: Date().timeIntervalSince1970,
            subInfo: DummySubInfo.subInfo,
            reports: nil,
            blocks: nil,
            chuCount: 150,
            isSubscribe: false
        )
        let user3 = User(
            mbti: .esfj,
            phoneNumber: "01023456789",
            gender: .female,
            birth: "0202",
            nickName: "나루토",
            location: Location(address: "주소", latitude: 0.0, longitude: 0.0),
            imageURLs: [],
            createdDate: Date().timeIntervalSince1970,
            subInfo: DummySubInfo.subInfo,
            reports: nil,
            blocks: nil,
            chuCount: 150,
            isSubscribe: false
        )
        
        let user4 = User(
            mbti: .infj,
            phoneNumber: "01023456789",
            gender: .female,
            birth: "0202",
            nickName: "사쿠라",
            location: Location(address: "주소", latitude: 0.0, longitude: 0.0),
            imageURLs: [],
            createdDate: Date().timeIntervalSince1970,
            subInfo: DummySubInfo.subInfo,
            reports: nil,
            blocks: nil,
            chuCount: 150,
            isSubscribe: false
        )
        
        let user5 = User(
            mbti: .estp,
            phoneNumber: "01023456789",
            gender: .female,
            birth: "0202",
            nickName: "사스케",
            location: Location(address: "주소", latitude: 0.0, longitude: 0.0),
            imageURLs: [],
            createdDate: Date().timeIntervalSince1970,
            subInfo: DummySubInfo.subInfo,
            reports: nil,
            blocks: nil,
            chuCount: 150,
            isSubscribe: false
        )
        
        let user6 = User(
            mbti: .intj,
            phoneNumber: "01023456789",
            gender: .female,
            birth: "0202",
            nickName: "프랑키",
            location: Location(address: "주소", latitude: 0.0, longitude: 0.0),
            imageURLs: [],
            createdDate: Date().timeIntervalSince1970,
            subInfo: DummySubInfo.subInfo,
            reports: nil,
            blocks: nil,
            chuCount: 150,
            isSubscribe: false
        )
        
        let user7 = User(
            mbti: .estj,
            phoneNumber: "01023456789",
            gender: .female,
            birth: "0202",
            nickName: "꼬마마법사도레미",
            location: Location(address: "주소", latitude: 0.0, longitude: 0.0),
            imageURLs: [],
            createdDate: Date().timeIntervalSince1970,
            subInfo: DummySubInfo.subInfo,
            reports: nil,
            blocks: nil,
            chuCount: 150,
            isSubscribe: false
        )
        
        let user8 = User(
            mbti: .entp,
            phoneNumber: "01023456789",
            gender: .female,
            birth: "0202",
            nickName: "박종욱",
            location: Location(address: "주소", latitude: 0.0, longitude: 0.0),
            imageURLs: [],
            createdDate: Date().timeIntervalSince1970,
            subInfo: DummySubInfo.subInfo,
            reports: nil,
            blocks: nil,
            chuCount: 150,
            isSubscribe: false
        )
       
        let user9 = User(
            mbti: .enfp,
            phoneNumber: "01012345678",
            gender: .male,
            birth: "0101",
            nickName: "펀치",
            location: Location(address: "주소", latitude: 0.0, longitude: 0.0),
            imageURLs: [],
            createdDate: Date().timeIntervalSince1970,
            subInfo: DummySubInfo.subInfo,
            reports: nil,
            blocks: nil,
            chuCount: 100,
            isSubscribe: true
        )
        
        let user10 = User(
            mbti: .infp,
            phoneNumber: "01023456789",
            gender: .female,
            birth: "0202",
            nickName: "오로마루",
            location: Location(address: "주소", latitude: 0.0, longitude: 0.0),
            imageURLs: [],
            createdDate: Date().timeIntervalSince1970,
            subInfo: DummySubInfo.subInfo,
            reports: nil,
            blocks: nil,
            chuCount: 150,
            isSubscribe: false
        )
        let user11 = User(
            mbti: .esfj,
            phoneNumber: "01023456789",
            gender: .female,
            birth: "0202",
            nickName: "보루토",
            location: Location(address: "주소", latitude: 0.0, longitude: 0.0),
            imageURLs: [],
            createdDate: Date().timeIntervalSince1970,
            subInfo: DummySubInfo.subInfo,
            reports: nil,
            blocks: nil,
            chuCount: 150,
            isSubscribe: false
        )
        
        let user12 = User(
            mbti: .infj,
            phoneNumber: "01023456789",
            gender: .female,
            birth: "0202",
            nickName: "사라",
            location: Location(address: "주소", latitude: 0.0, longitude: 0.0),
            imageURLs: [],
            createdDate: Date().timeIntervalSince1970,
            subInfo: DummySubInfo.subInfo,
            reports: nil,
            blocks: nil,
            chuCount: 150,
            isSubscribe: false
        )
        
        let user13 = User(
            mbti: .estp,
            phoneNumber: "01023456789",
            gender: .female,
            birth: "0202",
            nickName: "미케",
            location: Location(address: "주소", latitude: 0.0, longitude: 0.0),
            imageURLs: [],
            createdDate: Date().timeIntervalSince1970,
            subInfo: DummySubInfo.subInfo,
            reports: nil,
            blocks: nil,
            chuCount: 150,
            isSubscribe: false
        )
        
        let user14 = User(
            mbti: .intj,
            phoneNumber: "01023456789",
            gender: .female,
            birth: "0202",
            nickName: "초키",
            location: Location(address: "주소", latitude: 0.0, longitude: 0.0),
            imageURLs: [],
            createdDate: Date().timeIntervalSince1970,
            subInfo: DummySubInfo.subInfo,
            reports: nil,
            blocks: nil,
            chuCount: 150,
            isSubscribe: false
        )
        
        let user15 = User(
            mbti: .estj,
            phoneNumber: "01023456789",
            gender: .female,
            birth: "0202",
            nickName: "꼬마마법사애미",
            location: Location(address: "주소", latitude: 0.0, longitude: 0.0),
            imageURLs: [],
            createdDate: Date().timeIntervalSince1970,
            subInfo: DummySubInfo.subInfo,
            reports: nil,
            blocks: nil,
            chuCount: 150,
            isSubscribe: false
        )
        
        let user16 = User(
            mbti: .entp,
            phoneNumber: "01023456789",
            gender: .female,
            birth: "0202",
            nickName: "유민영",
            location: Location(address: "주소", latitude: 0.0, longitude: 0.0),
            imageURLs: [],
            createdDate: Date().timeIntervalSince1970,
            subInfo: DummySubInfo.subInfo,
            reports: nil,
            blocks: nil,
            chuCount: 150,
            isSubscribe: false
        )
        return [user1, user2, user3, user4, user5, user6, user7, user8, user9, user10, user11, user12, user13, user14, user15, user16]
    }()
}

struct DummySubInfo {
    static let subInfo: SubInfo = {
        return SubInfo(
            intro: "유저다",
            height: 157,
            drinkStatus: .usually,
            smokeStatus: .never,
            religion: .none,
            education: .university,
            job: "마법사",
            hobbies: ["아무거나", "화장실가기"],
            personalities: ["추악함", "포악함"],
            favoriteMBTIs: [.infj, .intj]
        )
    }()
}
