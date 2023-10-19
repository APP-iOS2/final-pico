//
//  MailReceiveModel.swift
//  Pico
//
//  Created by 양성혜 on 2023/10/05.
//

import UIKit
import RxSwift
import RxRelay
import FirebaseFirestore

final class MailReceiveModel {
    
    private(set) var receiveList: [Mail.MailInfo] = [] {
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
    private var itemsPerPage: Int = Int(Screen.height * 1.5 / 90)
    var startIndex = 0
    var user: User?
    
    struct Input {
        let listLoad: Observable<Void>
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
        
        DispatchQueue.global().async {
            ref.getDocument { [weak self] document, error in
                guard let self = self else { return }
                if let error = error {
                    print(error)
                    return
                }
                
                if let document = document, document.exists {
                    if let datas = try? document.data(as: Mail.self)
                        .receiveMailInfo?.filter({ $0.mailType == .receive }) {
                        if startIndex > datas.count - 1 {
                            return
                        }
                        let currentPageDatas: [Mail.MailInfo] = Array(datas[startIndex..<min(itemsPerPage, datas.count)])
                        receiveList.append(contentsOf: currentPageDatas)
                        startIndex += currentPageDatas.count
                    } else {
                        print("받은 문서를 찾을 수 없습니다.")
                    }
                }
                receiveList.sort(by: {$0.sendedDate > $1.sendedDate})
                
                reloadMailTableViewPublisher.onNext(())
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
    
    func getUser(userId: String, completion: @escaping () -> ()) {
        DispatchQueue.global().async {
            let query = self.dbRef.collection(Collections.users.name)
                .whereField("id", isEqualTo: userId)
            
            query.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print(error)
                } else {
                    for document in querySnapshot!.documents {
                        if let userdata = try? document.data(as: User.self) {
                            self.user = userdata
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    func updateNewData(data: Mail.MailInfo) {
        
        let updateData: Mail.MailInfo = Mail.MailInfo(id: data.id, sendedUserId: data.sendedUserId, receivedUserId: data.receivedUserId, mailType: data.mailType, message: data.message, sendedDate: data.sendedDate, isReading: true)
        
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
