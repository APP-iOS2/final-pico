//
//  WorldCupViewModel.swift
//  Pico
//
//  Created by 오영석 on 2023/10/10.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase

final class WorldCupViewModel {
    
    var users: BehaviorRelay<[User]> = BehaviorRelay(value: [])
    private let disposeBag = DisposeBag()
    
    init() {
        loadUsersRx()
    }
    
    func loadUsersRx() {
        FirestoreService.shared.loadDocumentRx(collectionId: .users, dataType: User.self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                
                let shuffledData = data.shuffled()
                
                let randomUsers = Array(shuffledData.prefix(8))
                
                self.users.accept(randomUsers)
            }, onError: { error in
                print("오류: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    func configure(cell: WorldCupCollectionViewCell, with user: User) {
        cell.mbtiLabel.text = user.mbti.rawValue
        cell.userNickname.text = user.nickName
        cell.userAge.text = "\(user.age)세"
        
        let dataLabelTexts = addDataLabels(user)
        cell.userInfoStackView.setDataLabelTexts(dataLabelTexts)
        
        if let imageURL = URL(string: user.imageURLs.first ?? "") {
            cell.userImage.load(url: imageURL)
        }
    }
    
    private func addDataLabels(_ currentUser: User) -> [String] {
        var dataLabelTexts: [String] = []

        if let height = currentUser.subInfo?.height {
            dataLabelTexts.append("\(height)")
        } else {
            dataLabelTexts.append("")
        }

        if let job = currentUser.subInfo?.job {
            dataLabelTexts.append("\(job)")
        } else {
            dataLabelTexts.append("")
        }

        dataLabelTexts.append("\(currentUser.location.address)")

        return dataLabelTexts
    }
}
