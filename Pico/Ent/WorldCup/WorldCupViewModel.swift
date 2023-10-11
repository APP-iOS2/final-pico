//
//  WorldCupViewModel.swift
//  Pico
//
//  Created by 오영석 on 2023/10/10.
//

import Foundation
import RxSwift
import RxCocoa

class WorldCupViewModel {
    
    var items: BehaviorRelay<[User]> = BehaviorRelay(value: [])
    var strong8: BehaviorRelay<[User]> = BehaviorRelay(value: [])
    var strong4: BehaviorRelay<[User]> = BehaviorRelay(value: [])
    var strong2: BehaviorRelay<[User]> = BehaviorRelay(value: [])
    var round: BehaviorRelay<Int> = BehaviorRelay(value: 16)
    
    private var index = 0
    
    init() {
        items.accept(DummyUserData.users)
    }
    
    func addDataLabels(_ currentItem: User) -> [String] {
        var dataLabelTexts: [String] = []
        
        if let height = currentItem.subInfo?.height {
            dataLabelTexts.append("\(height)")
        }
        
        if let job = currentItem.subInfo?.job {
            dataLabelTexts.append(job)
        }
        
        dataLabelTexts.append(currentItem.location.address)
        
        return dataLabelTexts
    }
    
    func handleSelection(indexPath: IndexPath) {
    }
}
