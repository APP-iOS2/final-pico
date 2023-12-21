//
//  NotificationViewModel.swift
//  Pico
//
//  Created by 방유빈 on 2023/10/04.
//

import Foundation
import RxSwift
import RxRelay
import FirebaseFirestore

final class NotificationViewModel: ViewModelType {
    var notifications: [Noti] = [] {
        didSet {
            if notifications.isEmpty {
                isEmptyPublisher.onNext(true)
            } else {
                isEmptyPublisher.onNext(false)
            }
        }
    }
    private let dbRef = Firestore.firestore()
    private let reloadTableViewPublisher = PublishSubject<Void>()
    private var isEmptyPublisher = PublishSubject<Bool>()
    private let disposeBag: DisposeBag = DisposeBag()
    private var itemsPerPage: Int = Int(Screen.height * 1.5 / 90)
    var lastDocumentSnapshot: DocumentSnapshot?

    struct Input {
        let listLoad: Observable<Void>
        let refresh: Observable<Void>
        let checkEmpty: Observable<Void>
        let deleteNoti: Observable<Noti>
    }
    
    struct Output {
        let reloadTableView: Observable<Void>
        let notificationIsEmpty: Observable<Bool>
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
                viewModel.loadNextPage()
            }
            .disposed(by: disposeBag)
        input.deleteNoti
            .withUnretained(self)
            .subscribe { viewModel, noti in
                viewModel.deleteNoti(noti: noti)
            }
            .disposed(by: disposeBag)
        
        let didset = isEmptyPublisher.asObservable()
            .map { result in
                return result
            }
        
        let check = input.checkEmpty
            .withUnretained(self)
            .map { viewModel, _ -> Bool in
                if viewModel.notifications.isEmpty {
                    return true
                } else {
                    return false
                }
            }
        let isEmpty = Observable.of(didset, check).merge()
            .flatMapLatest { bool -> Observable<Bool> in
                return Observable.create { emitter in
                    emitter.onNext(bool)
                    return Disposables.create()
                }
            }
        
        return Output(reloadTableView: reloadTableViewPublisher.asObservable(), notificationIsEmpty: isEmpty)
    }
    
    private func loadNextPage() {
        var query = dbRef.collection(Collections.notifications.name)
            .whereField("receiveId", isEqualTo: UserDefaultsManager.shared.getUserData().userId)
            .order(by: "createDate", descending: true)
            .limit(to: itemsPerPage)
        
        if let lastSnapshot = lastDocumentSnapshot {
            query = query.start(afterDocument: lastSnapshot)
        }
        
        DispatchQueue.global().async {
            query.getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print(error)
                    return
                }
                guard let documents = snapshot?.documents else { return }
                
                if documents.isEmpty {
                    return
                }
                
                lastDocumentSnapshot = documents.last
                
                for document in documents {
                    if let data = try? document.data(as: Noti.self) {
                        notifications.append(data)
                    }
                }
                reloadTableViewPublisher.onNext(())
            }
        }
    }
    
    private func refresh() {
        let didSet = isEmptyPublisher
        isEmptyPublisher = PublishSubject<Bool>()
        notifications = []
        lastDocumentSnapshot = nil
        isEmptyPublisher = didSet
        loadNextPage()
    }
    
    private func deleteNoti(noti: Noti) {
        if let notiId = noti.id {
            FirestoreService.shared.deleteDocument(collectionId: .notifications, documentId: notiId) { _ in
                print("삭제완료")
            }
        } else {
            FirestoreService.shared.deleteDocument(collectionId: .notifications, field: "createDate", isEqualto: noti.createDate, receiveId: noti.receiveId, sendId: noti.sendId)
        }
    }
}
