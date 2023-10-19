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
    private var percent = 20
    
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
        
        userAge.accept("\(ageComponents.year ?? 0)")
        loadUserData()
    }
    
    func loadUserData() {
        FirestoreService.shared.loadDocument(collectionId: .users, documentId: userDefaultsManager.userId, dataType: User.self) { result in
            switch result {
            case .success(let data):
                if let data {
                    self.imageUrl.accept(data.imageURLs[safe: 0] ?? self.userDefaultsManager.imageURL)
                    self.userName.accept(data.nickName)
                } else {
                    self.userName.accept(self.userDefaultsManager.nickName)
                    self.userName.accept(self.userDefaultsManager.imageURL)
                }
                self.percent = 20
                guard let subInfoData = data?.subInfo else {
                    self.profilePerfection.accept(self.percent)
                    return }
                
                if subInfoData.intro != nil {
                    self.percent += 10
                }
                if subInfoData.height != nil {
                    self.percent += 10
                }
                if subInfoData.drinkStatus != nil {
                    self.percent += 5
                }
                if subInfoData.smokeStatus != nil {
                    self.percent += 5
                }
                if subInfoData.religion != nil {
                    self.percent += 5
                }
                if subInfoData.education != nil {
                    self.percent += 5
                }
                if subInfoData.job != nil {
                    self.percent += 10
                }
                if subInfoData.hobbies != nil {
                    self.percent += 10
                }
                if subInfoData.personalities != nil {
                    self.percent += 10
                }
                if subInfoData.favoriteMBTIs != nil {
                    self.percent += 10
                }
                self.profilePerfection.accept(self.percent)
            case .failure(let err):
                self.profilePerfection.accept(self.percent)
                self.userName.accept(self.userDefaultsManager.nickName)
                self.imageUrl.accept(self.userDefaultsManager.imageURL)
                debugPrint(err)
            }
        }
    }
}
