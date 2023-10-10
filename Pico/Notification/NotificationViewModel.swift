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
        loadNotiRx()
            .bind(to: notifications)
            .disposed(by: disposBag)
    }
}

func loadNotiRx() -> Observable<[Noti]> {
    return Observable.create { emitter in
        FirestoreService().searchDocumentWithEqualField(collectionId: .notifications, field: "receiveId", compareWith: "qQ7WuQsq8vs6KrhVpFPe", dataType: Noti.self) { result in
            switch result {
            case .success(let data):
                guard let data = data else {
                    emitter.onNext([])
                    emitter.onCompleted()
                    break
                }
                emitter.onNext(data)
                emitter.onCompleted()
            case .failure(let error):
                emitter.onError(error)
            }
        }
        return Disposables.create()
    }
}
