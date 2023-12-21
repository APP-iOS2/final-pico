//
//  SettingSecessionViewModel.swift
//  Pico
//
//  Created by 김민기 on 2023/10/19.
//

import RxSwift
import RxCocoa

final class SettingSecessionViewModel: ViewModelType {
    
    let userId = UserDefaultsManager.shared.getUserData().userId
    
    struct Input {
        let isUnsubscribe: Observable<Void>
    }
    
    struct Output {
        let resultIsUnsubscribe: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        let responseUnsubscribe = input.isUnsubscribe
            .withUnretained(self)
            .flatMap { model, _ in
                FirestoreService.shared
                    .loadDocumentRx(collectionId: .users, documentId: model.userId, dataType: User.self)
                    .flatMap { data -> Observable<Void> in
                        return Observable.combineLatest(
                            model.saveData(data: data),
                            model.deleteData()
                        ).map { _, _ in
                            return Void()
                        }
                    }
            }
        
        return Output(resultIsUnsubscribe: responseUnsubscribe)
    }
    
    private func saveData(data: Codable) -> Observable<Void> {
        return FirestoreService.shared.saveDocumentRx(collectionId: .unsubscribe, documentId: userId, data: data)
            .asObservable()
    }
    
    private func deleteData() -> Observable<Void> {
        return FirestoreService.shared.deleteDocumentRx(collectionId: .users, documentId: userId)
            .asObservable()
    }
}
