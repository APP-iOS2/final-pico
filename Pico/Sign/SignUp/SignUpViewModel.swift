//
//  SignUpViewModel.swift
//  Pico
//
//  Created by LJh on 10/5/23.
//

import Foundation
import RxSwift
import RxRelay
import UIKit

final class SignUpViewModel {
    static var userMbti = "" // mbti타입에 맞게 소문자로 만들어야함
    static var phoneNumber: String = ""
    static var gender: GenderType = .etc
    static var birth: String = ""
    static var nickName: String = ""
    static var location: Location = Location(address: "", latitude: 0, longitude: 0)
    static var imageURLs: [UIImage] = [] // 스토리지에 넣고 돌려야함
    static var createdDate: Double = 0
    static var chuCount: Int = 0
    static var isSubscribe: Bool = false
}