//
//  NotificationViewModel.swift
//  Pico
//
//  Created by 방유빈 on 2023/10/04.
//

import Foundation
import RxSwift
import RxRelay

final class NotificationViewModel {
    var notifications = BehaviorRelay<[Noti]>(value: [])
    private let disposBag: DisposeBag = DisposeBag()
    
    init() {

    }
}
