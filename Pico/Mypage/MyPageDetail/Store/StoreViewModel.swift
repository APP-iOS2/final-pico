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
    
    private var currentChuCount = 0
    
    struct Input {
        /// 구매한 츄
        let purchaseChuCount: Observable<StoreModel>
        /// 사용한 츄
        let consumeChuCount: Observable<Int>
    }
    
    struct Output {
        let resultPurchase: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        let responsePurchase = input.purchaseChuCount
            .withUnretained(self)
            .flatMap { viewModel, storeModel in
                Loading.showLoading()
                viewModel.currentChuCount = storeModel.count + UserDefaultsManager.shared.getChuCount()
                return FirestoreService.shared.updateDocumentRx(collectionId: .users, documentId: viewModel.currentUser.userId, field: "chuCount", data: viewModel.currentChuCount)
                    .flatMap { _ -> Observable<Void> in
                        let payment: Payment.PaymentInfo = Payment.PaymentInfo(price: storeModel.price, purchaseChuCount: storeModel.count, paymentType: .purchase)
                        return FirestoreService.shared.saveDocumentRx(collectionId: .payment, documentId: viewModel.currentUser.userId, fieldId: "paymentInfos", data: payment)
                    }
            }
            .withUnretained(self)
            .map { viewModel, _ in
                UserDefaultsManager.shared.updateChuCount(viewModel.currentChuCount)
                return Loading.hideLoading()
            }
        return Output(
            resultPurchase: responsePurchase
        )
    }
    
    private func savePayment() {
        
    }
}
