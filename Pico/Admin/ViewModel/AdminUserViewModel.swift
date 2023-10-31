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

enum UserListType: CaseIterable {
    case using
    case unsubscribe
    
    var name: String {
        switch self {
        case .using:
            return "사용중인 회원"
        case .unsubscribe:
            return "탈퇴된 회원"
        }
    }
    
    var collectionId: Collections {
        switch self {
        case .using:
            return .users
        case .unsubscribe:
            return .unsubscribe
        }
    }
}

enum UserSortType: CaseIterable {
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
    
    var orderBy: (String, Bool) {
        switch self {
        case .dateDescending:
            return ("createdDate", true)
        case .dateAscending:
            return ("createdDate", false)
        case .nameDescending:
            return ("nickName", true)
        case .nameAscending:
            return ("nickName", false)
        case .ageDescending:
            return ("birth", true)
        case .ageAscending:
            return ("birth", false)
        }
    }
}

final class AdminUserViewModel: ViewModelType {
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let viewWillAppear: Observable<Void>
        let sortedType: Observable<UserSortType>
        let userListType: Observable<UserListType>
        let searchButton: Observable<String>
        let tableViewOffset: Observable<Void>
        let refreshable: Observable<Void>
    }
    
    struct Output {
        let resultToViewDidLoad: Observable<[User]>
        let resultTitleLabel: Observable<String>
        let resultSearchUserList: Observable<[User]>
        let resultPagingList: Observable<[User]>
        let needToReload: Observable<Void>
    }
    
    private let itemsPerPage: Int = 20
    private var lastDocumentSnapshot: DocumentSnapshot?
    
    private(set) var userList: [User] = []
    private let reloadPublisher = PublishSubject<Void>()
    
    func transform(input: Input) -> Output {
        let merged = Observable.merge(input.viewDidLoad, input.viewWillAppear)
        
        let responseViewDidLoad = Observable.combineLatest(input.userListType, input.sortedType, merged)
            .withUnretained(self)
            .flatMap { (viewModel, value) -> Observable<([User], DocumentSnapshot?)> in
                let (userListType, sortedType, _) = value
                return FirestoreService.shared.loadDocumentRx(collectionId: userListType.collectionId, dataType: User.self, orderBy: sortedType.orderBy, itemsPerPage: viewModel.itemsPerPage, lastDocumentSnapshot: nil)
            }
            .withUnretained(self)
            .map { viewModel, usersAndSnapshot in
                let (users, snapShot) = usersAndSnapshot
                viewModel.userList.removeAll()
                viewModel.lastDocumentSnapshot = snapShot
                viewModel.userList = users
                Loading.hideLoading()
                return viewModel.userList
            }
        
        _ = input.viewWillAppear
            .withUnretained(self)
            .subscribe(onNext: { viewModel, _ in
                viewModel.reloadPublisher.onNext(())
            })
        
        let sortedType = input.sortedType.asObservable()
        let userListType = input.userListType.asObservable()
        
        let responseTitleLabel = input.userListType
            .map { userListType in
                return "\"\(userListType.name)\"의 이름을 입력하세요"
            }
        
        let responseTableViewPaging = input.tableViewOffset
            .withUnretained(self)
            .flatMap { (viewModel, _) -> Observable<[User]> in
                return sortedType
                    .map { sortType in
                        return userListType
                            .flatMap { usrListType in
                                return viewModel.loadNextPage(collectionId: usrListType.collectionId, orderBy: sortType.orderBy)
                            }
                    }
                    .switchLatest()
            }
            .map { users in
                self.userList = users
                return self.userList
            }
        
        let responseSearchButton = input.searchButton
            .withUnretained(self)
            .flatMap { viewModel, textFieldText in
                if textFieldText.isEmpty {
                    return Observable.just(viewModel.userList)
                } else {
                    return FirestoreService.shared.searchDocumentWithEqualFieldRx(collectionId: .users, field: "nickName", compareWith: textFieldText, dataType: User.self)
                }
            }
        
        let responseTextFieldSearch = input.searchButton
            .withUnretained(self)
            .flatMap { viewModel, textFieldText in
                return viewModel.searchListTextField(viewModel.userList, textFieldText)
            }
        
        let combinedResults = Observable.zip(responseSearchButton, responseTextFieldSearch)
            .map { searchList, textFieldList in
                let list = searchList + textFieldList
                let setList = Set(list)
                return Array(setList)
            }
        
        return Output(
            resultToViewDidLoad: responseViewDidLoad,
            resultTitleLabel: responseTitleLabel,
            resultSearchUserList: combinedResults,
            resultPagingList: responseTableViewPaging,
            needToReload: reloadPublisher.asObservable()
        )
    }
    
    private func searchListTextField(_ userList: [User], _ text: String) -> Observable<[User]> {
        return Observable.create { emitter in
            let users = userList.filter { sortedUser in
                sortedUser.nickName.contains(text)
            }
            emitter.onNext(users)
            return Disposables.create()
        }
    }
    
    private func loadNextPage(collectionId: Collections, orderBy: (String, Bool)) -> Observable<[User]> {
        let dbRef = Firestore.firestore()
        var query = dbRef.collection(collectionId.name)
            .order(by: orderBy.0, descending: orderBy.1)
            .limit(to: itemsPerPage)
        
        if let lastSnapshot = lastDocumentSnapshot {
            query = query.start(afterDocument: lastSnapshot)
        }
        
        return Observable.create { [weak self] emitter in
            guard let self = self else { return Disposables.create()}
            
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
