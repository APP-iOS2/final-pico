//
//  HomeViewModel.swift
//  Pico
//
//  Created by 임대진 on 10/5/23.
//
import RxSwift
import RxRelay
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation

final class HomeViewModel {
    
    var users = BehaviorRelay<[User]>(value: [])
    var myLikes = BehaviorRelay<[Like.LikeInfo]>(value: [])
    var blocks = BehaviorRelay<[Block.BlockInfo]>(value: [])
    static var filterGender: [GenderType] = GenderType.allCases
    static var filterMbti: [MBTIType] = MBTIType.allCases
    static var filterAgeMin: Int = calculateAge(type: "min")
    static var filterAgeMax: Int = calculateAge(type: "max")
    static var filterDistance: Int = 501
    private let loginUser = UserDefaultsManager.shared.getUserData()
    private let disposeBag = DisposeBag()
    private var age: Int {
        let calendar = Calendar.current
        let currentDate = Date()
        let birthdate = UserDefaultsManager.shared.getUserData().birth.toDate()
        let ageComponents = calendar.dateComponents([.year], from: birthdate, to: currentDate)
        return ageComponents.year ?? 0
    }
    init() {
        loadFilterDefault()
        loadMySendBlocks()
        loadMyLikesRx()
        loadUsersCodable()
    }
    
    private static func calculateAge(type: String?) -> Int {
        let calendar = Calendar.current
        let currentDate = Date()
        let birthdate = UserDefaultsManager.shared.getUserData().birth.toDate()
        let ageComponents = calendar.dateComponents([.year], from: birthdate, to: currentDate)
        var age: Int
        if type == "min" {
            age = Int(ageComponents.year ?? 24) - 5
            if age >= 60 { age = 59 }
            age = max(age, 19)
        } else {
            age = Int(ageComponents.year ?? 34) + 5
            age = min(age, 60)
        }
        return age
    }

    func calculateDistance(user: User) -> CLLocationDistance {
        let currentUserLoc = CLLocation(latitude: loginUser.latitude, longitude: loginUser.longitude)
        let otherUserLoc = CLLocation(latitude: user.location.latitude, longitude: user.location.longitude)
        return  currentUserLoc.distance(from: otherUserLoc)
    }
    
    private func loadUsersRx() {
        FirestoreService.shared.loadDocumentRx(collectionId: .users, dataType: User.self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                print("유저 로드: \(data)명")
                self.users.accept(data)
            }, onError: { error in
                print("오류: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    private func loadUsersCodable() {
        var gender: [GenderType] = []
        
        if HomeViewModel.filterGender.isEmpty {
            gender = GenderType.allCases
        } else {
            gender = HomeViewModel.filterGender
        }
        
        DispatchQueue.global().async {
            let dbRef = Firestore.firestore()
            let query = dbRef.collection("users")
                .whereField("gender", in: gender.map { $0.rawValue })
                .order(by: "createdDate", descending: true)
            
            query.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print(error)
                } else {
                    var users = [User]()
                    for document in querySnapshot!.documents {
                        if let userdata = try? document.data(as: User.self) {
                            if userdata.id != self.loginUser.userId && userdata.id.prefix(4) != "test" {
                                users.append(userdata)
                            }
                        } else {
                            print("사용자 데이터 파싱 실패: \(document.documentID)")
                        }
                    }
                    DispatchQueue.main.async {
                        self.users.accept(users)
                        print("문서 유저 로드: \(users.count)명")
                    }
                }
            }
        }
    }
    
    private func loadMySendBlocks() {
        let blockCollectionRef = Firestore.firestore().collection("users").document(loginUser.userId).collection("Block").document(loginUser.userId)
        blockCollectionRef.getDocument { (document, error) in
            if let error = error {
                print("문서를 가져오는 중 오류 발생: \(error)")
            } else if let document = document, document.exists {
                var blockInfos = [Block.BlockInfo]()
                if let data = try? document.data(as: Block.self) {
                    if let sendData = data.sendBlock {
                        blockInfos.append(contentsOf: sendData)
                    }
                    self.blocks.accept(blockInfos)
                } else {
                    print("문서 데이터가 없음")
                }
            } else {
                print("문서가 존재하지 않음")
            }
        }
    }
    
    private func loadMyLikesRx() {
        FirestoreService.shared.loadDocumentRx(collectionId: .likes, documentId: UserDefaultsManager.shared.getUserData().userId, dataType: Like.self)
            .map { like -> [Like.LikeInfo] in
                if let like = like {
                    return like.sendedlikes ?? []
                }
                return []
            }
            .bind(to: myLikes)
            .disposed(by: disposeBag)
    }
    
    private func loadFilterDefault() {
        if let filterAgeMin = UserDefaults.standard.object(forKey: UserDefaultsManager.Key.filterAgeMin.rawValue) as? Int {
            HomeViewModel.filterAgeMin = filterAgeMin
        }
        
        if let filterAgeMax = UserDefaults.standard.object(forKey: UserDefaultsManager.Key.filterAgeMax.rawValue) as? Int {
            HomeViewModel.filterAgeMax = filterAgeMax
        }
        
        if let filterDistance = UserDefaults.standard.object(forKey: UserDefaultsManager.Key.filterDistance.rawValue) as? Int {
            HomeViewModel.filterDistance = filterDistance
        }
        
        if let genderData = UserDefaults.standard.object(forKey: UserDefaultsManager.Key.filterGender.rawValue) as? Data,
           let filterGender = try? JSONDecoder().decode([GenderType].self, from: genderData) {
            HomeViewModel.filterGender = filterGender
        }
        
        if let mbtiData = UserDefaults.standard.object(forKey: UserDefaultsManager.Key.filterMbti.rawValue) as? Data,
           let filterMbti = try? JSONDecoder().decode([MBTIType].self, from: mbtiData) {
            HomeViewModel.filterMbti = filterMbti
        }
    }
}
