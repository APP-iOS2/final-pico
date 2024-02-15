//
//  MailReceiveViewModel.swift
//  Pico
//
//  Created by 양성혜 on 2023/10/05.
//

import UIKit
import RxSwift
import RxRelay
import FirebaseFirestore

final class MailReceiveViewModel {
    
    private(set) var receiveList: [DirectMail.MailInfo] = [] {
        didSet {
            if receiveList.isEmpty {
                isReceiveEmptyPublisher.onNext(true)
            } else {
                isReceiveEmptyPublisher.onNext(false)
            }
        }
    }
    
    private var isReceiveEmptyPublisher = PublishSubject<Bool>()
    private let reloadMailTableViewPublisher = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    
    private let dbRef = Firestore.firestore()
    private var itemsPerPage: Int = Int(Screen.height * 1.5 / 60)
    var startIndex = 0
    
    struct Input {
        let listLoad: Observable<Void>
        let deleteUser: Observable<String>
        let refresh: Observable<Void>
        let isReceiveEmptyChecked: Observable<Void>
    }
    
    struct Output {
        let receiveIsEmpty: Observable<Bool>
        let reloadMailTableView: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        input.refresh
            .withUnretained(self)
            .subscribe { viewModel, _ in
                viewModel.refresh()
            }
            .disposed(by: disposeBag)
        
        input.listLoad
            .withUnretained(self)
            .subscribe { viewModel, _ in
                viewModel.loadNextMailPage()
            }
            .disposed(by: disposeBag)
        
        input.deleteUser
            .withUnretained(self)
            .subscribe { viewModel, mailId in
                viewModel.deleteMail(mailId: mailId)
            }
            .disposed(by: disposeBag)
        
        let didReceiveset = isReceiveEmptyPublisher.asObservable()
            .map { result in
                return result
            }
        let receiveCheck = input.isReceiveEmptyChecked
            .withUnretained(self)
            .map { viewModel, _ -> Bool in
                if viewModel.receiveList.isEmpty {
                    return true
                } else {
                    return false
                }
            }
        let isReceiveEmpty = Observable.of(didReceiveset, receiveCheck).merge()
            .flatMapLatest { bool -> Observable<Bool> in
                return Observable.create { emitter in
                    emitter.onNext(bool)
                    return Disposables.create()
                }
            }
        
        return Output(receiveIsEmpty: isReceiveEmpty, reloadMailTableView: reloadMailTableViewPublisher.asObservable())
    }
    
    func loadNextMailPage() {
        let ref = dbRef.collection(Collections.mail.name)
            .document(UserDefaultsManager.shared.getUserData().userId)
        
        let endIndex = startIndex + itemsPerPage
        
        DispatchQueue.global().async {
            ref.getDocument { [weak self] document, error in
                guard let self = self else { return }
                if let error = error {
                    print(error)
                    return
                }
                
                if let document = document, document.exists {
                    if let datas = try? document.data(as: DirectMail.self)
                        .receiveMailInfo?.filter({ $0.mailType == .receive }) {
                        let sorted = datas.sorted {
                            return $0.sendedDate > $1.sendedDate
                        }
                        if startIndex > sorted.count - 1 {
                            return
                        }
                        let currentPageDatas: [DirectMail.MailInfo] = Array(sorted[startIndex..<min(endIndex, sorted.count)])
                        receiveList += currentPageDatas
                        
                        if startIndex == 0 {
                            reloadMailTableViewPublisher.onNext(())
                        }
                        
                        startIndex += currentPageDatas.count
                    }
                } else {
                    print("받은 문서를 찾을 수 없습니다.")
                }
            }
        }
    }
    
    private func refresh() {
        let didSet = isReceiveEmptyPublisher
        isReceiveEmptyPublisher = PublishSubject<Bool>()
        receiveList = []
        startIndex = 0
        isReceiveEmptyPublisher = didSet
        loadNextMailPage()
    }
    
    private func deleteMail(mailId: String) {
        let currentUser = UserDefaultsManager.shared.getUserData()
        
        guard let index = receiveList.firstIndex(where: {
            $0.id == mailId
        }) else {
            return
        }
        guard let removeData: DirectMail.MailInfo = receiveList[safe: index] else {
            print("삭제 실패: 해당 유저 정보 얻기 실패")
            return
        }
        receiveList.remove(at: index)
        reloadMailTableViewPublisher.onNext(())
        
        dbRef.collection(Collections.mail.name).document(currentUser.userId).updateData([
            "receiveMailInfo": FieldValue.arrayRemove([removeData.asDictionary()])
        ])
    }
    
    func updateNewData(data: DirectMail.MailInfo) {
        let updateData: DirectMail.MailInfo = DirectMail.MailInfo(id: data.id, sendedUserId: data.sendedUserId, receivedUserId: data.receivedUserId, mailType: data.mailType, message: data.message, sendedDate: data.sendedDate, isReading: true)
        
        DispatchQueue.global().async {
            self.dbRef.collection(Collections.mail.name).document(UserDefaultsManager.shared.getUserData().userId).updateData([
                "receiveMailInfo": FieldValue.arrayRemove([data.asDictionary()])
            ])
            self.dbRef.collection(Collections.mail.name).document(UserDefaultsManager.shared.getUserData().userId).updateData([
                "receiveMailInfo": FieldValue.arrayUnion([updateData.asDictionary()])
            ])
        }
    }
    
    func toType (text: String) -> MailType {
        switch text {
        case "받은 쪽지":
            return .receive
        case "보낸 쪽지":
            return .send
        default:
            return .receive
        }
    }
}
