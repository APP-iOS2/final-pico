//
//  ProfileEditViewModel.swift
//  Pico
//
//  Created by 김민기 on 2023/10/11.
//

import RxSwift
import RxCocoa

final class ProfileEditViewModel {
    
    enum SubInfoCase {
        case height
        case education
        case religion
        case drink
        case smoke
        case job
        case personalities
        case hobbies
        case favoriteMBTIs
        
        var name: String {
            switch self {
            case .height:
                return "키"
            case .education:
                return "학력"
            case .religion:
                return "종교"
            case .drink:
                return "음주"
            case .smoke:
                return "흡연"
            case .job:
                return "직업"
            case .personalities:
                return "나의 성격"
            case .hobbies:
                return "나의 취미"
            case .favoriteMBTIs:
                return "선호하는 MBTI"
            }
        }
    }
    
    private let userId = UserDefaultsManager.shared.getUserData().userId
    let sectionsRelay = BehaviorRelay<[SectionModel]>(value: [
        SectionModel(items: [.profileEditImageTableCell]),
        SectionModel(items: [.profileEditNicknameTabelCell, .profileEditLoactionTabelCell(location: "")]),
        SectionModel(items: [
            .profileEditIntroTabelCell(content: ""),
            .profileEditTextTabelCell(title: SubInfoCase.height.name, content: nil),
            .profileEditTextTabelCell(title: SubInfoCase.education.name, content: nil),
            .profileEditTextTabelCell(title: SubInfoCase.religion.name, content: nil),
            .profileEditTextTabelCell(title: SubInfoCase.drink.name, content: nil),
            .profileEditTextTabelCell(title: SubInfoCase.smoke.name, content: nil),
            .profileEditTextTabelCell(title: SubInfoCase.job.name, content: nil),
            .profileEditTextTabelCell(title: SubInfoCase.personalities.name, content: nil),
            .profileEditTextTabelCell(title: SubInfoCase.hobbies.name, content: nil),
            .profileEditTextTabelCell(title: SubInfoCase.favoriteMBTIs.name, content: nil)
        ])
    ])
    
    init() {
        loadUserData()
    }

    func loadUserData() {
        FirestoreService.shared.loadDocument(collectionId: .users, documentId: userId, dataType: User.self) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                guard let data else { return }
                let result =
                [
                    SectionModel(items: [.profileEditImageTableCell]),
                    SectionModel(items: [.profileEditNicknameTabelCell, .profileEditLoactionTabelCell(location: data.location.address)]),
                    SectionModel(items: [
                        .profileEditIntroTabelCell(content: data.subInfo?.intro ?? ""),
                        .profileEditTextTabelCell(title: SubInfoCase.height.name, content: "\(data.subInfo?.height ?? 0)"),
                    .profileEditTextTabelCell(title: SubInfoCase.education.name, content: data.subInfo?.education.rawValue),
                    .profileEditTextTabelCell(title: SubInfoCase.religion.name, content: data.subInfo?.religion.rawValue),
                    .profileEditTextTabelCell(title: SubInfoCase.drink.name, content: data.subInfo?.drinkStatus.rawValue),
                    .profileEditTextTabelCell(title: SubInfoCase.smoke.name, content: data.subInfo?.smokeStatus.rawValue),
                    .profileEditTextTabelCell(title: SubInfoCase.job.name, content: data.subInfo?.job),
                    .profileEditTextTabelCell(title: SubInfoCase.personalities.name, content: data.subInfo?.personalities[0]),
                    .profileEditTextTabelCell(title: SubInfoCase.hobbies.name, content: data.subInfo?.hobbies[0]),
                    .profileEditTextTabelCell(title: SubInfoCase.favoriteMBTIs.name, content: data.subInfo?.favoriteMBTIs[0].rawValue)
                        ])
                    ]
                sectionsRelay.accept(result)
            case .failure(let err):
                debugPrint(err)
            }
        }
    }
}
