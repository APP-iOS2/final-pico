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

final class NotificationViewModel {
    var notifications: [Noti] = []
    var notificationsRx = BehaviorRelay<[Noti]>(value: [])
    private let disposBag: DisposeBag = DisposeBag()
    private var itemsPerPage: Int = 10
    var lastDocumentSnapshot: DocumentSnapshot?
    
    init() {
        loadNextPage()
    }
    
    func loadNextPage() {
        let dbRef = Firestore.firestore()
        
        var query = dbRef.collection(Collections.notifications.name)
            .whereField("receiveId", isEqualTo: UserDefaultsManager.shared.getUserData().userId)
            .order(by: "createDate", descending: true)
            .limit(to: itemsPerPage)
        
        if let lastSnapshot = lastDocumentSnapshot {
            query = query.start(afterDocument: lastSnapshot)
        }
        
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
            notificationsRx.accept(notifications)
        }
    }
}
