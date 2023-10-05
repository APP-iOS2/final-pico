//
//  ProfileViewModel.swift
//  Pico
//
//  Created by 김민기 on 2023/10/05.
//

import RxSwift
import RxCocoa

class ProfileViewModel {
    
    let disposeBag = DisposeBag()
    
    let circularProgressBarViewModel = CircularProgressBarViewModel()
    
    let userName = BehaviorRelay(value: "")
    let userAge = BehaviorRelay(value: "")
    let profilePerfection = BehaviorRelay(value: 0)
    
    init() {
        profilePerfection
            .map {
                let result = Double($0) / 100
               return result
            }
            .bind(to: circularProgressBarViewModel.profilePerfection)
            .disposed(by: disposeBag)
        
        profilePerfection.accept(20)
        userName.accept("패치값")
        userAge.accept("20")
    }
    
}
