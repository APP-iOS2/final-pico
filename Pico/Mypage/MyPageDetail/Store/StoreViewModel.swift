//
//  StoreViewModel.swift
//  Pico
//
//  Created by 최하늘 on 10/17/23.
//

import Foundation
import RxSwift

final class StoreViewModel: ViewModelType {
    private let currentUser: CurrentUser = UserDefaultsManager.shared.getUserData()
    let storeModels: [StoreModel] = [
        StoreModel(count: 50, price: 5500, discount: nil),
        StoreModel(count: 100, price: 11000, discount: nil),
        StoreModel(count: 500, price: 50000, discount: 10),
        StoreModel(count: 1000, price: 88000, discount: 20)
    ]
    
    struct Input {
        /// 구매한 츄 카운트
        let purchaseChuCount: Observable<Int>
        /// 사용한 츄 카운트
        let consumeChuCount: Observable<Int>
    }
    
    struct Output {
        let resultPurchase: Observable<Int>
    }
    
    func transform(input: Input) -> Output {
        let responsePurchase = input.purchaseChuCount
            .withUnretained(self)
            .flatMap { viewModel, purchaseChuCount in
                Loading.showLoading()
                return FirestoreService.shared.updateDocumentRx(collectionId: .users, documentId: viewModel.currentUser.userId, field: "chuCount", data: purchaseChuCount + UserDefaultsManager.shared.getChuCount())
            }
            .map { chuCount in
                UserDefaultsManager.shared.updateChuCount(chuCount)
                DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
                    Loading.hideLoading()
                }
                return chuCount
            }
        
        return Output(
            resultPurchase: responsePurchase
        )
    }
}
