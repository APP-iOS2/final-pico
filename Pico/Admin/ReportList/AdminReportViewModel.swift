//
//  AdminReportViewModel.swift
//  Pico
//
//  Created by 최하늘 on 10/23/23.
//

import Foundation
import RxSwift
import FirebaseFirestore

enum ReportSortType: CaseIterable {
    /// 신고일 내림차순, 최신순
    case dateDescending
    /// 신고일 오름차순
    case dateAscending
    /// 피신고자 내림차순
    case reportedNameDescending
    /// 피신고자 오름차순
    case reportedNameAscending
    /// 신고자 내림차순
    case reportNameDescending
    /// 신고자 오름차순
    case reportNameAscending
    
    var name: String {
        switch self {
        case .dateDescending:
            return "신고일 내림차순"
        case .dateAscending:
            return "신고일 오름차순"
        case .reportedNameDescending:
            return "피신고자 내림차순"
        case .reportedNameAscending:
            return "피신고자 오름차순"
        case .reportNameDescending:
            return "신고자 내림차순"
        case .reportNameAscending:
            return "신고자 오름차순"
        }
    }
    
    var orderBy: (String, Bool) {
        switch self {
        case .dateDescending:
            return ("createdDate", true)
        case .dateAscending:
            return ("createdDate", false)
        case .reportNameDescending:
            return ("reportNickname", true)
        case .reportNameAscending:
            return ("reportNickname", false)
        case .reportedNameDescending:
            return ("reportedNickname", true)
        case .reportedNameAscending:
            return ("reportedNickname", false)
        }
    }
}

final class AdminReportViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: Observable<ReportSortType>
        let searchButton: Observable<String>
        let tableViewOffset: Observable<Void>
        let reportedUserId: Observable<String>
    }
    
    struct Output {
        let resultToViewDidLoad: Observable<[AdminReport]>
        let resultSearchUserList: Observable<[AdminReport]>
        let resultPagingList: Observable<[AdminReport]>
        let resultReportedUser: Observable<User?>
    }
    
    var selectedSortType: ReportSortType = .dateDescending
    
    private let itemsPerPage: Int = 10
    private var lastDocumentSnapshot: DocumentSnapshot?
    
    private(set) var reportList: [AdminReport] = []
    
    func transform(input: Input) -> Output {
        let responseViewDidLoad = input.viewDidLoad
            .withUnretained(self)
            .flatMap { viewModel, reportSortType in
                Loading.hideLoading()
                viewModel.selectedSortType = reportSortType
                return FirestoreService.shared.loadDocumentRx(collectionId: .adminReport, dataType: AdminReport.self, orderBy: reportSortType.orderBy, itemsPerPage: viewModel.itemsPerPage, lastDocumentSnapshot: nil)
            }
            .withUnretained(self)
            .map { viewModel, usersAndSnapshot in
                let (reports, snapShot) = usersAndSnapshot
                viewModel.reportList.removeAll()
                viewModel.lastDocumentSnapshot = snapShot
                viewModel.reportList = reports
                Loading.hideLoading()
                return viewModel.reportList
            }
        
        let responseTableViewPaging = input.tableViewOffset
            .withUnretained(self)
            .flatMap { viewModel, _ in
                return viewModel.loadNextPage(collectionId: .adminReport, orderBy: viewModel.selectedSortType.orderBy)
            }
        
        let responseSearchButton = input.searchButton
            .withUnretained(self)
            .flatMap { viewModel, textFieldText in
                if textFieldText.isEmpty {
                    return Observable.just(viewModel.reportList)
                } else {
                    return FirestoreService.shared.searchDocumentWithEqualFieldRx(collectionId: .adminReport, field: "reportNickname", compareWith: textFieldText, dataType: AdminReport.self)
                }
            }
        
        let responseTextFieldSearch = input.searchButton
            .withUnretained(self)
            .flatMap { viewModel, textFieldText in
                return viewModel.searchListTextField(viewModel.reportList, textFieldText)
            }
        
        let combinedResults = Observable.zip(responseSearchButton, responseTextFieldSearch)
            .map { searchList, textFieldList in
                let list = searchList + textFieldList
                let setList = Set(list)
                return Array(setList)
            }
        
        let responseReportedUser = input.reportedUserId
            .flatMap { reportedUserId in
                return FirestoreService.shared.loadDocumentRx(collectionId: .users, documentId: reportedUserId, dataType: User.self)
            }
            .map { user in
                return user
            }
        
        return Output(
            resultToViewDidLoad: responseViewDidLoad,
            resultSearchUserList: combinedResults,
            resultPagingList: responseTableViewPaging,
            resultReportedUser: responseReportedUser
        )
    }
    
    private func searchListTextField(_ reportList: [AdminReport], _ text: String) -> Observable<[AdminReport]> {
        return Observable.create { emitter in
            let reports = reportList.filter { user in
                user.reportNickname.contains(text)
            }
            emitter.onNext(reports)
            return Disposables.create()
        }
    }
    
    private func loadNextPage(collectionId: Collections, orderBy: (String, Bool)) -> Observable<[AdminReport]> {
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
                        if let data = try? document.data(as: AdminReport.self) {
                            reportList.append(data)
                        }
                    }
                    emitter.onNext(reportList)
                }
            }
            return Disposables.create()
        }
    }
}
