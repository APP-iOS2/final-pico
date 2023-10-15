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
    var notifications: [Noti] = []
    private let reloadTableViewPublisher = PublishSubject<Void>()
    private let disposeBag: DisposeBag = DisposeBag()
    private var itemsPerPage: Int = Int(Screen.height * 1.5 / 90)
    var lastDocumentSnapshot: DocumentSnapshot?

    struct Input {
        let listLoad: Observable<Void>
        let refresh: Observable<Void>
    }
    
    struct Output {
        let reloadTableView: Observable<Void>
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
        
        return Output(reloadTableView: reloadTableViewPublisher.asObservable())
    }
    
    private func loadNextPage() {
        let dbRef = Firestore.firestore()
        
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
        notifications = []
        lastDocumentSnapshot = nil
        loadNextPage()
    }
}
