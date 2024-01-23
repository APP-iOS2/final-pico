//
//  ProfileEditViewModel.swift
//  Pico
//
//  Created by 김민기 on 2023/10/11.
//

import RxSwift
import RxCocoa
import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

final class ProfileEditViewModel {
    
    enum SubInfoCase {
        case imageURLs
        case nickName
        case mbti
        case location
        case intro
        case height
        case job
        case religion
        case drink
        case smoke
        case education
        case personalities
        case hobbies
        case favoriteMBTIs
        
        var name: String {
            switch self {
            case .nickName:
                return "이름변경"
            case .intro:
                return "한 줄 소개"
            case .mbti:
                return "MBTI"
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
            default:
                return ""
            }
        }
        
        var dataName: String {
            switch self {
            case .imageURLs:
                return "imageURLs"
            case .nickName:
                return "nickName"
            case .mbti:
                return "mbti"
            case .location:
                return "location"
            case .intro:
                return "subInfo.intro"
            case .height:
                return "subInfo.height"
            case .job:
                return "subInfo.job"
            case .religion:
                return "subInfo.religion"
            case .drink:
                return "subInfo.drinkStatus"
            case .smoke:
                return "subInfo.smokeStatus"
            case .education:
                return "subInfo.education"
            case .personalities:
                return "subInfo.personalities"
            case .hobbies:
                return "subInfo.hobbies"
            case .favoriteMBTIs:
                return "subInfo.favoriteMBTIs"
            }
        }
    }
    
    let frequencyType = FrequencyType.allCases.map { $0.name }
    let frequencyTypes: [FrequencyType] = FrequencyType.allCases
    let religionType = ReligionType.allCases.map { $0.name }
    let educationType = EducationType.allCases.map { $0.name }
    
    let modalName = BehaviorRelay<String>(value: "")
    var modalCollectionData = [String]()
    var modalType: SubInfoCase?
    
    private var imagesSubject: PublishSubject<[UIImage]> = PublishSubject()
    private var urlStringsSubject: PublishSubject<[String]> = PublishSubject()
    private let disposeBag = DisposeBag()
    
    var selectedIndex: Int?/*컬렉션뷰만잇는뷰에서 사용*/
    var selectedIndexs: [Int]?/*컬렉션뷰만잇는뷰에서 사용*/
    var textData: String? /*텍스트만잇는뷰 사용*/
    var collectionData: [String]? /*콜렉션텍스트뷰 사용*/
    var userImages: [UIImage]?
    
    var userData: User?
    
    let dbRef = Firestore.firestore()
    
    private let userId = UserDefaultsManager.shared.getUserData().userId
    let sectionsRelay = BehaviorRelay<[SectionModel]>(value: [
        SectionModel(items: [.profileEditImageTableCell(images: [])]),
        SectionModel(items: [.profileEditNicknameTabelCell, .profileEditLoactionTabelCell(location: "")]),
        SectionModel(items: [
            .profileEditTextTabelCell(title: SubInfoCase.intro.name, content: nil),
            .profileEditTextTabelCell(title: SubInfoCase.height.name, content: nil),
            .profileEditTextTabelCell(title: SubInfoCase.job.name, content: nil),
            .profileEditTextTabelCell(title: SubInfoCase.religion.name, content: nil),
            .profileEditTextTabelCell(title: SubInfoCase.drink.name, content: nil),
            .profileEditTextTabelCell(title: SubInfoCase.smoke.name, content: nil),
            .profileEditTextTabelCell(title: SubInfoCase.education.name, content: nil),
            .profileEditTextTabelCell(title: SubInfoCase.personalities.name, content: nil),
            .profileEditTextTabelCell(title: SubInfoCase.hobbies.name, content: nil),
            .profileEditTextTabelCell(title: SubInfoCase.favoriteMBTIs.name, content: nil)
        ])
    ])
    
    private let profileViewModel: ProfileViewModel
    
    init(profileViewModel: ProfileViewModel) {
        self.profileViewModel = profileViewModel
        loadUserData()
        binds()
    }
    
    func binds() {
        imagesSubject
            .flatMap { images -> Observable<[String]> in
                return StorageService.shared.getUrlStrings(images: images, userId: UUID().uuidString)
            }
            .subscribe(onNext: urlStringsSubject.onNext(_:))
            .disposed(by: disposeBag)
        
        urlStringsSubject
            .subscribe { [weak self] strings in
                guard let self else { return }
                self.collectionData?.append(contentsOf: strings)
                self.updateUserData(data: self.collectionData?.first, selectedCase: .imageURLs)
                self.updateData(data: self.collectionData)
            }.disposed(by: disposeBag)
    }
    
    func saveImage() {
        imagesSubject.onNext(userImages ?? [])
    }
    
    func compareChuCount() -> Bool {
        let chuCount = UserDefaultsManager.shared.getChuCount()
        guard chuCount >= 50 else { return false }
        return true
    }
    
    func findIndex(for targetString: String, in array: [String]) -> Int? {
        if let index = array.firstIndex(of: targetString) {
            return index
        }
        return nil
    }
    
    func findMbtiIndex(for targetStrings: [String], in array: [String]) -> [Int] {
        var indexs = [Int]()
        for targetString in targetStrings {
            if let index = array.firstIndex(of: targetString) {
                indexs.append(index)
            }
        }
        return indexs
    }
    
    func convertLikeData(data: String, selectedCase: SubInfoCase, likeData: Like.LikeInfo) -> Like.LikeInfo? {
        switch selectedCase {
        case .imageURLs:
            return Like.LikeInfo(likedUserId: likeData.likedUserId, likeType: likeData.likeType, birth: likeData.birth, nickName: likeData.nickName, mbti: likeData.mbti, imageURL: data, createdDate: likeData.createdDate)
        case .nickName:
            return Like.LikeInfo(likedUserId: likeData.likedUserId, likeType: likeData.likeType, birth: likeData.birth, nickName: data, mbti: likeData.mbti, imageURL: likeData.imageURL, createdDate: likeData.createdDate)
        case .mbti:
            return nil
        default:
            return nil
        }
    }
    
    func updataLikesdata(data: String, selectedCase: SubInfoCase) async {
        let likesdocument = dbRef.collection("likes")
        do {
            let querySnapshot = try await likesdocument.getDocuments()
            for document in querySnapshot.documents {
                let documentID = document.documentID
                if let temp = try? document.data(as: Like.self) {
                    for i in temp.recivedlikes ?? [] {
                        if i.likedUserId == self.userId {

                            guard let updateData = convertLikeData(data: data, selectedCase: selectedCase, likeData: i) else { return }
                            
                            DispatchQueue.global().async { [weak self] in
                                guard let self = self else { return }
                                
                                dbRef.collection(Collections.likes.name).document(documentID).updateData([
                                    "recivedlikes": FieldValue.arrayRemove([i.asDictionary()])
                                ]) { error in
                                    if let error = error {
                                        debugPrint("매칭 업데이트 실패(라이크 데이터 삭제 실패): \(error)")
                                    }
                                }
                                
                                dbRef.collection(Collections.likes.name).document(documentID).updateData([
                                    "recivedlikes": FieldValue.arrayUnion([updateData.asDictionary()])
                                ]) { error in
                                    if let error = error {
                                        debugPrint("매칭 업데이트 실패(라이크 데이터 추가 실패): \(error)")
                                    }
                                }
                            }
                        }
                    }
                    
                    for i in temp.sendedlikes ?? [] {
                        if i.likedUserId == self.userId {
                            guard let updateData = convertLikeData(data: data, selectedCase: selectedCase, likeData: i) else { return }
                            
                            DispatchQueue.global().async { [weak self] in
                                guard let self = self else { return }
                                
                                dbRef.collection(Collections.likes.name).document(documentID).updateData([
                                    "sendedlikes": FieldValue.arrayRemove([i.asDictionary()])
                                ]) { error in
                                    if let error = error {
                                        debugPrint("매칭 업데이트 실패(라이크 데이터 삭제 실패): \(error)")
                                    }
                                }
                                
                                dbRef.collection(Collections.likes.name).document(documentID).updateData([
                                    "sendedlikes": FieldValue.arrayUnion([updateData.asDictionary()])
                                ]) { error in
                                    if let error = error {
                                        debugPrint("매칭 업데이트 실패(라이크 데이터 추가 실패): \(error)")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } catch {
            debugPrint("Error getting documents: \(error)")
        }
    }
    
    func updateNotisData(data: String, selectedCase: SubInfoCase) async {
        var field = ""
        switch selectedCase {
        case .imageURLs:
            field = "imageUrl"
        case .nickName:
            field = "name"
        case .mbti:
            field = "mbti"
        default:
            break
        }
        do {
            let querySnapshot = try await dbRef.collection("notifications")
                .whereField("sendId", isEqualTo: userId)
                .getDocuments()
            for document in querySnapshot.documents {
                let documentID = document.documentID
                FirestoreService.shared.updateDocument(collectionId: .notifications, documentId: documentID, field: field, data: data) { result in
                    switch result {
                    case .success(let data):
                        debugPrint("업데이트 성공 \(data)")
                    case .failure(let error):
                        debugPrint("업데이트 실패, 에러메시지 : \(error)")
                    }
                }
            }
        } catch {
            debugPrint("Error updateing documents: \(error)")
        }
    }
    
    func updateUserData<T: Codable>(data: T, selectedCase: SubInfoCase) {
        guard let data = data as? String else { return }
        Task {
            await updataLikesdata(data: data, selectedCase: selectedCase)
        }
        Task {
            await updateNotisData(data: data, selectedCase: selectedCase)
        }
    }
    
    func updateData<T: Codable>(data: T) {
        guard let field = modalType?.dataName else { return }
        
        if modalType == .location {
            Loading.showLoading(title: "위치정보를 받는중이에요!")
            FirestoreService.shared.updateDocuments(collectionId: .users, documentId: userId, field: field, data: data) { _ in
                Loading.hideLoading()
            }
        } else {
            FirestoreService.shared.updateDocument(collectionId: .users, documentId: userId, field: field, data: data) { result in
                switch result {
                case .success(let data):
                    debugPrint("업데이트 성공 \(data)")
                case .failure(let error):
                    debugPrint("업데이트 실패, 에러메시지 : \(error)")
                }
            }
        }
        loadUserData()
        profileViewModel.loadUserData()
    }
    
    func transformArrtoString<T: StringProtocol>(stringArr: [T]) -> String {
        var text = ""
        for index in 0..<stringArr.count {
            text += stringArr[index]
            if index < stringArr.count - 1 {
                text += ","
            }
        }
        return text
    }
    
    func transformEnumtoString<T: RawRepresentable>(stringArr: [T]) -> String {
        var text = ""
        for index in 0..<stringArr.count {
            let value = stringArr[index].rawValue as? String ?? ""
            text += value.uppercased()
            if index < stringArr.count - 1 {
                text += ","
            }
        }
        return text
    }
    
    func loadUserData() {
        Loading.showLoading()
        FirestoreService.shared.loadDocument(collectionId: .users, documentId: userId, dataType: User.self) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                Loading.hideLoading()
                if let user = data {
                    UserDefaultsManager.shared.setUserData(userData: user)
                }
                guard let data else { return }
                userData = data
                let result =
                [
                    SectionModel(items: [.profileEditImageTableCell(images: data.imageURLs)]),
                    SectionModel(items: [.profileEditNicknameTabelCell, .profileEditLoactionTabelCell(location: data.location.address)]),
                    SectionModel(items: [
                        .profileEditTextTabelCell(title: SubInfoCase.intro.name, content: data.subInfo?.intro),
                        .profileEditTextTabelCell(title: SubInfoCase.height.name, content: data.subInfo?.height != nil ? "\(data.subInfo?.height ?? 0)cm" : nil),
                        .profileEditTextTabelCell(title: SubInfoCase.job.name, content: data.subInfo?.job),
                        .profileEditTextTabelCell(title: SubInfoCase.religion.name, content: data.subInfo?.religion?.name),
                        .profileEditTextTabelCell(title: SubInfoCase.drink.name, content: data.subInfo?.drinkStatus?.name),
                        .profileEditTextTabelCell(title: SubInfoCase.smoke.name, content: data.subInfo?.smokeStatus?.name),
                        .profileEditTextTabelCell(title: SubInfoCase.education.name, content: data.subInfo?.education?.name),
                        .profileEditTextTabelCell(title: SubInfoCase.personalities.name, content: transformArrtoString(stringArr: data.subInfo?.personalities ?? [])),
                        .profileEditTextTabelCell(title: SubInfoCase.hobbies.name, content: transformArrtoString(stringArr: data.subInfo?.hobbies ?? [])),
                        .profileEditTextTabelCell(title: SubInfoCase.favoriteMBTIs.name, content: transformEnumtoString(stringArr: data.subInfo?.favoriteMBTIs ?? []))
                    ])
                ]
                sectionsRelay.accept(result)
            case .failure(let err):
                debugPrint(err)
                Loading.hideLoading()
            }
        }
    }
}
