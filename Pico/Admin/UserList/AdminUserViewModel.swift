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
    case dateAscending
    case dateDescending
    case nameAscending
    case nameDescending
    case ageAscending
    case ageDescending
    
    var name: String {
        switch self {
        case .dateAscending:
            return "가입일 오름차순"
        case .dateDescending:
            return "가입일 내림차순"
        case .nameAscending:
            return "이름 오름차순"
        case .nameDescending:
            return "이름 내림차순"
        case .ageAscending:
            return "나이 오름차순"
        case .ageDescending:
            return "나이 내림차순"
        }
    }
}

enum FilterType: CaseIterable {
    case name
    case mbti
    
    var name: String {
        switch self {
        case .name:
            return "이름"
        case .mbti:
            return "MBTI"
        }
    }
}

final class AdminUserViewModel {
    private let disposeBag = DisposeBag()
    let userList = BehaviorRelay<[User]>(value: [])
    
    var selectedSortType: BehaviorRelay<SortType> = BehaviorRelay(value: .dateAscending)
    var selectedFilteredType: BehaviorSubject<FilterType> = BehaviorSubject(value: .name)
    
    var sortedUsers: Observable<[User]> {
        return Observable.combineLatest(selectedSortType, userList)
            .map { sortType, users in
                switch sortType {
                case .dateAscending:
                    return users.sorted { $0.createdDate < $1.createdDate }
                case .dateDescending:
                    return users.sorted { $0.createdDate > $1.createdDate }
                case .nameAscending:
                    return users.sorted { $0.nickName < $1.nickName }
                case .nameDescending:
                    return users.sorted { $0.nickName > $1.nickName }
                case .ageAscending:
                    return users.sorted { $0.age < $1.age }
                case .ageDescending:
                    return users.sorted { $0.age > $1.age }
                }
            }
    }
    
    var filteredUsers: Observable<[User]> {
        return Observable.combineLatest(selectedFilteredType, sortedUsers)
            .map { filterType, users in
                switch filterType {
                case .name:
                    Loading.hideLoading()
                    return users.filter { sortedUser in
                        !sortedUser.nickName.contains("") || sortedUser.phoneNumber.contains("8888")
                    }
                case .mbti:
                    return users
                }
            }
    }
    
    init() {
        FirestoreService.shared.loadDocumentRx(collectionId: .users, dataType: User.self)
            .subscribe { [weak self] event in
                switch event {
                case .next(let users):
                    self?.userList.accept(users)
                case .error(let error):
                    print(error)
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
    }
    
    func updateSelectedSortType(to sortType: SortType) {
        selectedSortType.accept(sortType)
    }
    
    func updateSelectedFilterType(to filterType: FilterType) {
        selectedFilteredType.onNext(filterType)
    }
}
