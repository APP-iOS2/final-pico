//
//  WorldCupResultViewModel.swift
//  Pico
//
//  Created by 방유빈 on 2023/10/19.
//

import Foundation
import RxSwift
import FirebaseFirestore

class WorldCupResultViewModel: ViewModelType {
    private let dbRef = Firestore.firestore()
    private let currentUser = UserDefaultsManager.shared.getUserData()
    private var currentChuCount = UserDefaultsManager.shared.getChuCount()
    
    struct Input {
        let requestMessage: Observable<User>
    }
    
    struct Output {
        let resultRequestMessage: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        let resultRequestMessage = input.requestMessage
            .withUnretained(self)
            .flatMap { viewModel, resultUser -> Observable<Void> in
                Loading.showLoading()
                return viewModel.requestMessage(resultUser: resultUser)
            }
            .withUnretained(self)
            .flatMap { viewModel, _ -> Observable<Void> in  
                viewModel.currentChuCount = UserDefaultsManager.shared.getChuCount() - 25
                return FirestoreService.shared.updateDocumentRx(collectionId: .users, documentId: viewModel.currentUser.userId, field: "chuCount", data: viewModel.currentChuCount)
                    .flatMap { _ -> Observable<Void> in
                        let payment: Payment.PaymentInfo = Payment.PaymentInfo(price: 0, purchaseChuCount: -25, paymentType: .worldCup)
                        return FirestoreService.shared.saveDocumentRx(collectionId: .payment, documentId: viewModel.currentUser.userId, fieldId: "paymentInfos", data: payment)
                    }
            }
            .withUnretained(self)
            .map { viewModel, _ in
                UserDefaultsManager.shared.updateChuCount(viewModel.currentChuCount)
                return DispatchQueue.main.async {
                    Loading.hideLoading()
                }
            }
 
        return Output(resultRequestMessage: resultRequestMessage)
    }
    
    private func requestMessage(resultUser: User) -> Observable<Void> {
        return Observable.create { [weak self] emitter in
            guard let self = self else { return Disposables.create() }
            let newMail = DirectMail.MailInfo(sendedUserId: resultUser.id, receivedUserId: currentUser.userId, mailType: .receive, message: "월드컵 우승자에게 메일을 보내보세요!", sendedDate: Date().timeIntervalSince1970, isReading: false)
            dbRef.collection(Collections.mail.name).document(currentUser.userId).setData(
                [
                    "userId": currentUser.userId,
                    "receiveMailInfo": FieldValue.arrayUnion([newMail.asDictionary()])
                ], merge: true) { error in
                    if let error = error {
                        print("평가 업데이트 에러: \(error)")
                        emitter.onError(error)
                    } else {
                        print("평가 업데이트 성공")
                        emitter.onNext(())
                    }
                }
            return Disposables.create()
        }
    }
}
