//
//  ProfileEditModalViewModel.swift
//  Pico
//
//  Created by 김민기 on 2023/10/13.
//

import RxSwift
import RxCocoa

final class ProfileEditNicknameModalViewModel {
    
    private let currentUser: CurrentUser = UserDefaultsManager.shared.getUserData()
    private var currentChuCount = 0
    
    struct Input {
        /// 사용한 츄
        let consumeChuCount: Observable<Void>
    }
    
    struct Output {
        let resultPurchase: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        let responsePurchase = input.consumeChuCount
            .withUnretained(self)
            .flatMap { viewModel, _ in
                Loading.showLoading()
                viewModel.currentChuCount =
                UserDefaultsManager.shared.getChuCount() - 50
                return FirestoreService.shared.updateDocumentRx(collectionId: .users, documentId: viewModel.currentUser.userId, field: "chuCount", data: viewModel.currentChuCount)
                    .flatMap { _ -> Observable<Void> in
                        let payment: Payment.PaymentInfo = Payment.PaymentInfo(price: 0, purchaseChuCount: -50, paymentType: .changeNickname)
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
}
