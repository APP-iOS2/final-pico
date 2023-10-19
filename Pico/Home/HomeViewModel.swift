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
    
    var otherUsers = BehaviorRelay<[User]>(value: [])
    var myLikes = BehaviorRelay<[Like.LikeInfo]>(value: [])
    static var filterGender: [GenderType] = []
    static var filterMbti: [MBTIType] = []
    static var filterAgeMin: Int = 24
    static var filterAgeMax: Int = 34
    static var filterDistance: Int = 501
    private let loginUser = UserDefaultsManager.shared.getUserData()
    private let disposeBag = DisposeBag()
    
    init() {
        loadFilterDefault()
        loadUsers()
        loadMyLikesRx()
    }
    
    func calculateDistance(user: User) -> CLLocationDistance {
        let currentUserLoc = CLLocation(latitude: loginUser.latitude, longitude: loginUser.longitude)
        let otherUserLoc = CLLocation(latitude: user.location.latitude, longitude: user.location.longitude)
        return  currentUserLoc.distance(from: otherUserLoc)
    }
    
    private func loadUsers() {
        var gender: [GenderType] = []
        
        if HomeViewModel.filterGender.isEmpty {
            gender = GenderType.allCases
        } else {
            gender = HomeViewModel.filterGender
        }
        
        DispatchQueue.global().async {
            let dbRef = Firestore.firestore()
            let query = dbRef.collection("users")
                .whereField("id", isNotEqualTo: self.loginUser.userId)
                .whereField("gender", in: gender.map { $0.rawValue })
            
            query.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print(error)
                } else {
                    var users = [User]()
                    for document in querySnapshot!.documents {
                        var blocks: Block = Block(userId: "")
                        var reports: Report = Report(userId: "")
                        var subInfos: SubInfo = SubInfo(intro: "", height: 0, drinkStatus: .never, smokeStatus: .never, religion: .buddhism, education: .college, job: "", hobbies: [], personalities: [], favoriteMBTIs: [])
                        
                        self.queryBlocks(for: document.documentID) { block in
                            blocks = block ?? Block(userId: nil)
                        }
                        self.queryReports(for: document.documentID) { report in
                            reports = report ?? Report(userId: nil)
                        }
                        self.querySubInfo(for: document.documentID) { subInfo in
                            subInfos = subInfo ?? SubInfo(intro: "", height: 0, drinkStatus: .never, smokeStatus: .never, religion: .buddhism, education: .college, job: "", hobbies: [], personalities: [], favoriteMBTIs: [])
                        }
                        
                        if let id = document["id"] as? String,
                           let mbtiTypeRawValue = document["mbti"] as? String,
                           let mbtiType = MBTIType(rawValue: mbtiTypeRawValue),
                           let phoneNumber = document["phoneNumber"] as? String,
                           let genderTypeRawValue = document["gender"] as? String,
                           let genderType = GenderType(rawValue: genderTypeRawValue),
                           let birth = document["birth"] as? String,
                           let nickName = document["nickName"] as? String,
                           let locationData = document["location"] as? [String: Any],
                           let address = locationData["address"] as? String,
                           let latitude = locationData["latitude"] as? Double,
                           let longitude = locationData["longitude"] as? Double,
                           let imageURLs = document["imageURLs"] as? [String],
                           let createdDate = document["createdDate"] as? Double {
                            let user = User(id: id, mbti: mbtiType, phoneNumber: phoneNumber, gender: genderType, birth: birth, nickName: nickName, location: Location(address: address, latitude: latitude, longitude: longitude), imageURLs: imageURLs, createdDate: createdDate, subInfo: subInfos, reports: [reports], blocks: [blocks], chuCount: 0, isSubscribe: false)
                            users.append(user)
                        }
                    }
                    self.otherUsers.accept(users)
                    print(users.count)
                }
            }
        }
    }
    
    private func querySubInfo(for userId: String, completion: @escaping (SubInfo?) -> Void) {
        let dbRef = Firestore.firestore()
        let userDocument = dbRef.collection("users").document(userId)
        
        userDocument.getDocument { (document, error) in
            if let error = error {
                print("Error querying subInfo: \(error)")
                completion(nil)
            } else {
                if let subInfoData = document?.get("subInfo") as? [String: Any] {
                    var subInfo: SubInfo?
                    if let subInfoData = subInfoData["subInfo"] as? [String: Any] {
                        let intro = subInfoData["intro"] as? String
                        let height = subInfoData["height"] as? Int
                        let drinkStatusRawValue = subInfoData["drinkStatus"] as? String
                        let drinkStatus = FrequencyType(rawValue: drinkStatusRawValue ?? "")
                        let smokeStatusRawValue = subInfoData["smokeStatus"] as? String
                        let smokeStatus = FrequencyType(rawValue: smokeStatusRawValue ?? "")
                        let religionRawValue = subInfoData["religion"] as? String
                        let religion = ReligionType(rawValue: religionRawValue ?? "")
                        let educationRawValue = subInfoData["education"] as? String
                        let education = EducationType(rawValue: educationRawValue ?? "")
                        let job = subInfoData["job"] as? String
                        let hobbies = subInfoData["hobbies"] as? [String]
                        let personalities = subInfoData["personalities"] as? [String]
                        
                        var favoriteMBTIs: [MBTIType] = []
                        if let favoriteMBTIsData = subInfoData["favoriteMBTIs"] as? [String] {
                            favoriteMBTIs = favoriteMBTIsData.compactMap { MBTIType(rawValue: $0) }
                        }
                        
                        subInfo = SubInfo(intro: intro, height: height, drinkStatus: drinkStatus, smokeStatus: smokeStatus, religion: religion, education: education, job: job, hobbies: hobbies, personalities: personalities, favoriteMBTIs: favoriteMBTIs)
                    }
                    completion(subInfo)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    private func queryReports(for userId: String, completion: @escaping (Report?) -> Void) {
        let dbRef = Firestore.firestore()
        let blocksCollection = dbRef.collection("users").document(userId).collection("Report").document(userId)
        blocksCollection.getDocument { snapshot, error in
            if let snapshot = snapshot, snapshot.exists {
                do {
                    let documentData = try snapshot.data(as: Report.self)
                    completion(documentData)
                } catch {
                    print("Error to decode document data: \(error)")
                }
            } else {
                completion(nil)
            }
        }
    }
    
    private func queryBlocks(for userId: String, completion: @escaping (Block?) -> Void) {
        let dbRef = Firestore.firestore()
        let blocksCollection = dbRef.collection("users").document(userId).collection("Block").document(userId)
        blocksCollection.getDocument { snapshot, error in
            if let snapshot = snapshot, snapshot.exists {
                do {
                    let documentData = try snapshot.data(as: Block.self)
                    completion(documentData)
                } catch {
                    print("Error to decode document data: \(error)")
                }
            } else {
                completion(nil)
            }
        }
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
                .whereField("id", isNotEqualTo: self.loginUser.userId)
                .whereField("gender", in: gender.map { $0.rawValue })
            
            query.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print(error)
                } else {
                    var users = [User]()
                    for document in querySnapshot!.documents {
                        var user: User?
                        var blocks: Block = Block(userId: "")
                        var reports: Report = Report(userId: "")
                        var subInfos: SubInfo = SubInfo(intro: "", height: 0, drinkStatus: .never, smokeStatus: .never, religion: .buddhism, education: .college, job: "", hobbies: [], personalities: [], favoriteMBTIs: [])
                        
                        self.queryBlocks(for: document.documentID) { block in
                            blocks = block ?? Block(userId: "")
                        }
                        self.queryReports(for: document.documentID) { report in
                            reports = report ?? Report(userId: "")
                        }
                        self.querySubInfo(for: document.documentID) { subInfo in
                            subInfos = subInfo ?? SubInfo(intro: "", height: 0, drinkStatus: .never, smokeStatus: .never, religion: .buddhism, education: .college, job: "", hobbies: [], personalities: [], favoriteMBTIs: [])
                        }
                        
                        if let userdata = try? document.data(as: User.self) {
                            user = userdata
                            user?.subInfo = subInfos
                            user?.blocks = [blocks]
                            user?.reports = [reports]
                            users.append(user ?? User.userData)
                        }
                    }
                    self.otherUsers.accept(users)
                    print(users.count)
                    
                }
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
