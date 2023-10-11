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
    
    var index = 0
    
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
    
    func tappedGameCell(indexPath: IndexPath) {
        guard let item = items.value[safe: indexPath.item] else {
            return
        }
        print(index)

        switch round.value {
        case 16:
            strong8.accept(strong8.value + [item])
        case 8:
            strong4.accept(strong4.value + [item])
        case 4:
            strong2.accept(strong2.value + [item])
        case 2:
            break
        default:
            break
        }
        
        index += 1
        round.accept(round.value / 2)
        
        if round.value == 0 {
            items.accept(strong2.value)
        } else {
            items.accept(items.value.dropFirst(2).map { $0 })
        }
    }
}
