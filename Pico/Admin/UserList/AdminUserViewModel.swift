//
//  AdminUserViewModel.swift
//  Pico
//
//  Created by 최하늘 on 10/6/23.
//

import Foundation
import RxSwift
import RxCocoa

// 질문: enum 을 여기에서만 쓰는데 어디에다 관리하는 게 좋을까용~?
enum SortType: CaseIterable {
    case dateDescending
    case dateAscending
    case nameDescending
    case nameAscending
    case ageDescending
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
    
    private(set) var userList: [User] = []
    private(set) var sortedList: [User] = []
    private(set) var filteredList: [User] = [] {
        didSet {
            reloadPublisher.onNext(())
        }
    }
    private let reloadPublisher = PublishSubject<Void>()

    struct Input {
        let viewDidLoad: Observable<Void>
        let sortedTpye: Observable<SortType>
        let resultTextField: Observable<String>
    }
    
    struct Output {
        let resultToViewDidLoad: Observable<[User]>
        let needToReload: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        let responseViewDidLoad = Observable.combineLatest(input.sortedTpye, input.viewDidLoad)
            .flatMapLatest { sortedType, _ in
                return FirestoreService.shared.loadDocumentRx(collectionId: .users, dataType: User.self)
                    .withUnretained(self)
                    .map { viewModel, userList in
                        viewModel.userList = userList
                        viewModel.sortedList = viewModel.sortUserList(userList, by: sortedType)
                        return viewModel.sortedList
                    }
            }

        return Output(
            resultToViewDidLoad: responseViewDidLoad,
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
        print("adf \(text)")
        let users = userList.filter { sortedUser in
            sortedUser.nickName.contains(text) || sortedUser.phoneNumber.contains("8888")
        }
        return users
    }
}
