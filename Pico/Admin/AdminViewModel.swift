//
//  AdminViewModel.swift
//  Pico
//
//  Created by 최하늘 on 10/6/23.
//

import Foundation
import RxSwift
import RxCocoa

final class AdminViewModel {
    // Inputs
    let searchText = BehaviorRelay<String?>(value: nil)
    let selectedSortType = BehaviorRelay<AdminViewController.SortType>(value: .dateAscending)
    let selectedFilteredType = BehaviorRelay<AdminViewController.FilterType>(value: .name)
    
    // Outputs
    let filteredUsers: Driver<[AdminViewController.DummyUser]>
    let sortedUsers: Driver<[AdminViewController.DummyUser]>
    
    init(users: [AdminViewController.DummyUser]) {
        // Filtered Users
        // Intermediate Observable for filteredUsers
        let filteredUsersObservable = Observable.combineLatest(searchText, selectedFilteredType)
            .map { searchText, filterType in
                guard let searchText = searchText, !searchText.isEmpty else {
                    return users
                }
                
                switch filterType {
                case .name:
                    return users.filter { $0.name.lowercased().contains(searchText.lowercased()) }
                case .mbti:
                    // Handle MBTI filtering here if needed
                    return users
                }
            }

        // Convert to Driver
        filteredUsers = filteredUsersObservable
            .asDriver(onErrorJustReturn: [])

        // Sorted Users
        // Intermediate Observable for sortedUsers
        let sortedUsersObservable = Observable.combineLatest(filteredUsersObservable, selectedSortType)
            .map { filteredUsers, sortType in
                switch sortType {
                case .dateAscending:
                    return filteredUsers.sorted { $0.createdDate < $1.createdDate }
                case .dateDescending:
                    return filteredUsers.sorted { $0.createdDate > $1.createdDate }
                case .nameAscending:
                    return filteredUsers.sorted { $0.name < $1.name }
                case .nameDescending:
                    return filteredUsers.sorted { $0.name > $1.name }
                case .ageAscending:
                    return filteredUsers.sorted { $0.age < $1.age }
                case .ageDescending:
                    return filteredUsers.sorted { $0.age > $1.age }
                }
            }

        // Convert to Driver
        sortedUsers = sortedUsersObservable
            .asDriver(onErrorJustReturn: [])
    }
}
