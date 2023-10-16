//
//  AdminUserViewModel.swift
//  Pico
//
//  Created by 최하늘 on 10/6/23.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseFirestore

// 질문: enum 을 여기에서만 쓰는데 어디에다 관리하는 게 좋을까용~?
enum SortType: CaseIterable {
    /// 가입일 내림차순
    case dateDescending
    /// 가입일 오름차순
    case dateAscending
    /// 이름 내림차순
    case nameDescending
    /// 이름 오름차순
    case nameAscending
    /// 나이 내림차순
    case ageDescending
    /// 나이 오름차순
    case ageAscending
    
    var name: String {
        switch self {
        case .dateDescending:
            return "가입일 내림차순"
        case .dateAscending:
            return "가입일 오름차순"
        case .nameDescending:
            return "이름 내림차순"
        case .nameAscending:
            return "이름 오름차순"
        case .ageDescending:
            return "나이 내림차순"
        case .ageAscending:
            return "나이 오름차순"
        }
    }
}

final class AdminUserViewModel: ViewModelType {
    private let itemsPerPage: Int = 5
    private var lastDocumentSnapshot: DocumentSnapshot?
    
    private(set) var userList: [User] = []
    private let reloadPublisher = PublishSubject<Void>()

    struct Input {
        let viewDidLoad: Observable<Void>
        let sortedTpye: Observable<SortType>
        let searchButton: Observable<String>
        let tableViewOffset: Observable<Void>
        let refresh: Observable<Void>
    }
    
    struct Output {
        let resultToViewDidLoad: Observable<[User]>
        let resultSortedUserList: Observable<[User]>
        let resultSearchUserList: Observable<[User]>
        let resultPagingList: Observable<[User]>
        let needToReload: Observable<Void>
    }
    //  질문: withUnretained 이거 바로 아래밖에 적용이 안되는지 ?
    func transform(input: Input) -> Output {
        let responseViewDidLoad = Observable.merge(input.refresh, input.viewDidLoad)
            .withUnretained(self)
            .flatMap { (viewModel, _) -> Observable<([User], DocumentSnapshot?)> in
                return FirestoreService.shared.loadDocumentRx(collectionId: .users, dataType: User.self, itemsPerPage: viewModel.itemsPerPage, lastDocumentSnapshot: nil)
            }
            .map { users, snapShot in
                self.userList.removeAll()
                self.lastDocumentSnapshot = snapShot
                self.userList = users
                Loading.hideLoading()
                return self.userList
            }
        
        let responseTableViewPaging = input.tableViewOffset
            .withUnretained(self)
            .flatMap { (viewModel, _) -> Observable<[User]> in
                Loading.showLoading()
                return viewModel.loadNextPage()
            }
            .map { users in
                self.userList = users
                Loading.hideLoading()
                return self.userList
            }
        
        let responseSorted = input.sortedTpye
            .withUnretained(self)
            .flatMapLatest { viewModel, sortedType in
                return Observable.just(viewModel.sortUserList(viewModel.userList, by: sortedType))
            }
        
        let responseSearchButton = input.searchButton
            .withUnretained(self)
            .flatMapLatest { viewModel, textFieldText in
                return Observable.just(viewModel.filterUserList(viewModel.userList, textFieldText))
            }
        
        return Output(
            resultToViewDidLoad: responseViewDidLoad,
            resultSortedUserList: responseSorted,
            resultSearchUserList: responseSearchButton,
            resultPagingList: responseTableViewPaging,
            needToReload: reloadPublisher.asObservable()
        )
    }
    
    private func sortUserList(_ userList: [User], by sortType: SortType) -> [User] {
        switch sortType {
        case .dateDescending:
            return userList.sorted { $0.createdDate > $1.createdDate }
        case .dateAscending:
            return userList.sorted { $0.createdDate < $1.createdDate }
        case .nameDescending:
            return userList.sorted { $0.nickName > $1.nickName }
        case .nameAscending:
            return userList.sorted { $0.nickName < $1.nickName }
        case .ageDescending:
            return userList.sorted { $0.age > $1.age }
        case .ageAscending:
            return userList.sorted { $0.age < $1.age }
        }
    }
    
    private func filterUserList(_ userList: [User], _ text: String) -> [User] {
        if text.isEmpty {
            return userList
        } else {
            let users = userList.filter { sortedUser in
                sortedUser.nickName.contains(text)
            }
            return users
        }
    }
    
    private func loadNextPage() -> Observable<[User]> {
        let dbRef = Firestore.firestore()
        
        return Observable.create { [weak self] emitter in
            guard let self = self else { return Disposables.create()}
            
            var query = dbRef.collection(Collections.users.name)
//                .order(by: "createdDate", descending: true)
                .limit(to: itemsPerPage)
            
            if let lastSnapshot = lastDocumentSnapshot {
                query = query.start(afterDocument: lastSnapshot)
            }
            
            DispatchQueue.global().async {
                query.getDocuments { [weak self] snapshot, error in
                    guard let self = self else { return }
                    if let error = error {
                        emitter.onError(error)
                        return
                    }
                    guard let documents = snapshot?.documents else { return }
                    
                    if documents.isEmpty {
                        Loading.hideLoading()
                        return
                    }
                    
                    lastDocumentSnapshot = documents.last
                    
                    for document in documents {
                        if let data = try? document.data(as: User.self) {
                            userList.append(data)
                        }
                    }
                    emitter.onNext(userList)
                }
            }
            return Disposables.create()
        }
    }
}
