//
//  ProfileEditModalViewModel.swift
//  Pico
//
//  Created by 김민기 on 2023/10/13.
//

import RxSwift
import RxCocoa

final class ProfileEditModalViewModel {
    enum TableCase {
        case smoke
        case drink
        case rel
        case education
    }
    let frequencyType = FrequencyType.allCases.map { $0.name }
    let religionType = ReligionType.allCases.map { $0.name }
    let educationType = EducationType.allCases.map { $0.name }
    
    let data = BehaviorRelay<[String]>(value: [])
    let name = BehaviorRelay<String>(value: "아맞다ㅡㅡ")
    var type: TableCase?
    init() {
    
    }
 
    func updateData() {
        
    }
}
