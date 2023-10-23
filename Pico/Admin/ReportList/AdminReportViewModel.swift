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
    }
    
    struct Output {
        let resultToViewDidLoad: Observable<[AdminReport]>
    }
    
    private let itemsPerPage: Int = 15
    private var lastDocumentSnapshot: DocumentSnapshot?
    
    private(set) var reportList: [AdminReport] = []

    func transform(input: Input) -> Output {
        let responseViewDidLoad = input.viewDidLoad
            .withUnretained(self)
            .flatMap { viewModel, reportSortType in
                Loading.hideLoading()
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
        
        return Output(
            resultToViewDidLoad: responseViewDidLoad
        )
    }
}
