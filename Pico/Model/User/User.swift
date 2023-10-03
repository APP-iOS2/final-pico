//
//  User.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import Foundation

struct User: Codable {
    var id: String = UUID().uuidString
    let mbti: MBTIType
    let phoneNumber: String
    let gender: GenderType
    let birth: String
    let nickName: String
    let location: Location
    let imageURLs: [String]
    let createdDate: Double
    
    /// 추가정보
    let subInfo: SubInfo?
    /// 나를 신고한 기록
    let reports: [Report]?
    /// 내가 차단한 기록
    let blocks: [Block]?
    
    let chuCount: Int
    let isSubscribe: Bool
}

enum GenderType: Codable {
    case male
    case female
    case etc
}

extension User {
    // User MockUpData
    static let userData = User(mbti: .infp, phoneNumber: "01012341234", gender: .male, birth: "0131", nickName: "윈터", location: Location(address: "서울특별시 강남구", latitude: 10, longitude: 10),
                               imageURLs: ["https://image5jvqbd.fmkorea.com/files/attach/new2/20211225/3655109/3113058505/4195166827/e130faca7194985e4f162b3583d52853.jpg",
                                           "https://i.namu.wiki/i/jUHcYJjORbNSurOw8cwl-g8jduAT01mhJJkF5oDbvyae_1hkSExnUQ0I5fDKgebUKzSFjSFhRheeSI9-rfpuDU8RJ9wqo5KwIodMVjuzKT2o6RK0IutUtsKWZrYxzT-cOvxKhbPm9c3PXo5H-OvBCA.webp",
                                           "https://img.dmitory.com/img/202107/2lh/a8H/2lha8HnRr6Q046GGGQ0uwM.jpg",
                                           "https://img.dmitory.com/img/202107/2lh/a8H/2lha8HnRr6Q046GGGQ0uwM.jpg"],
                               createdDate: 10, subInfo: SubInfo(intro: "안녕하세요", height: 160, drinkStatus: .nomal, smokeStatus: .never, religion: .none, education: .university, job: "개발자", hobbies: ["산책", "개발", "게임하기", "집밖에서 술 마시기", "기다 등등", "기다 등등", "기다 등등", "기다 등등", "기다 등등"], personalities: ["재미가 없어요", "말이많아요", "말이많아요", "말이많아요", "말이많아요", "솔직해요"], favoriteMBTIs: [.enfj, .enfp]), reports: nil, blocks: nil, chuCount: 1000, isSubscribe: false)
    
    static let userData2 = User(mbti: .infp, phoneNumber: "01046275953", gender: .male, birth: "0131", nickName: "희권", location: Location(address: "경기도 부천시", latitude: 10, longitude: 10), imageURLs: [], createdDate: 10, subInfo: nil, reports: nil, blocks: nil, chuCount: 0, isSubscribe: false)
}
