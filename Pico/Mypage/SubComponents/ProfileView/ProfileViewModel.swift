//
//  ProfileViewModel.swift
//  Pico
//
//  Created by 김민기 on 2023/10/05.
//

import RxSwift
import RxCocoa
import Foundation

final class ProfileViewModel {
    
    private let disposeBag = DisposeBag()
    private let userDefaultsManager = UserDefaultsManager.shared.getUserData()

    let circularProgressBarViewModel = CircularProgressBarViewModel()
    
    let userName = BehaviorRelay(value: "")
    let userAge = BehaviorRelay(value: "")
    let profilePerfection = BehaviorRelay(value: 0)
    let imageUrl = BehaviorRelay(value: "")
    
    init() {
        profilePerfection
            .map {
                let result = Double($0) / 100
               return result
            }
            .bind(to: circularProgressBarViewModel.profilePerfection)
            .disposed(by: disposeBag)
        
        let calendar = Calendar.current
        let currentDate = Date()
        let birthdate = userDefaultsManager.birth.toDate()
        let ageComponents = calendar.dateComponents([.year], from: birthdate, to: currentDate)
        
        profilePerfection.accept(20)
        userName.accept(userDefaultsManager.nickName)
        userAge.accept("\(ageComponents.year ?? 0)")
        imageUrl.accept(userDefaultsManager.imageURL)
    }
    
}
