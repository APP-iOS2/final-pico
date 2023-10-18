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
                            let user = User(id: id, mbti: mbtiType, phoneNumber: phoneNumber, gender: genderType, birth: birth, nickName: nickName, location: Location(address: address, latitude: latitude, longitude: longitude), imageURLs: imageURLs, createdDate: createdDate, subInfo: nil, reports: nil, blocks: nil, chuCount: 0, isSubscribe: false)
                            users.append(user)
                        }
                    }
                    self.otherUsers.accept(users)
                    print(users.count)
                }
            }
        }
    }

//    private func loadUsers() {
//        var gender: [GenderType] = []
//        
//        if HomeViewModel.filterGender.isEmpty {
//            gender = GenderType.allCases
//        } else {
//            gender = HomeViewModel.filterGender
//        }
//        
//        DispatchQueue.global().async {
//            let dbRef = Firestore.firestore()
//            let query = dbRef.collection("users")
//                .whereField("id", isNotEqualTo: self.loginUser.userId)
//                .whereField("gender", in: gender.map { $0.rawValue })
//            
//            query.getDocuments { (querySnapshot, error) in
//                if let error = error {
//                    print(error)
//                } else {
//                    var users = [User]()
//                    for document in querySnapshot!.documents {
//                        if let userData = document.data() as? [String: Any] {
//                            var user = try? document.data(as: User.self)
//                            if user != nil {
//                                let userId = document.documentID
//                                
//                                self.querySubInfo(for: userId) { subInfo in
//                                    user?.subInfo = subInfo
//                                }
//                                self.queryReports(for: userId) { reports in
//                                    user?.reports = reports
//                                }
//                                self.queryBlocks(for: userId) { blocks in
//                                    user?.blocks = blocks
//                                }
//                                
//                                users.append(user!)
//                                print(users.count)
//                            }
//                        }
//                    }
//                    self.otherUsers.accept(users)
//                    print(users.count)
//                }
//            }
//        }
//    }
//    
    private func querySubInfo(for userId: String, completion: @escaping (SubInfo?) -> Void) {
        let dbRef = Firestore.firestore()
        let userDocument = dbRef.collection("users").document(userId)
        
        // Access the 'subinfo' field of the user document
        userDocument.getDocument { (document, error) in
            if let error = error {
                print("Error querying subInfo: \(error)")
                completion(nil)
            } else {
                if let subInfoData = document?.get("subinfo") as? [String: Any] {
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
    
    private func queryReports(for userId: String, completion: @escaping ([Report]?) -> Void) {
        let dbRef = Firestore.firestore()
        let reportsCollection = dbRef.collection("users").document(userId).collection("reports")
        
        reportsCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error querying reports: \(error)")
                completion(nil)
            } else {
                var reports = [Report]()
                for document in querySnapshot!.documents {
                    if let report = try? document.data(as: Report.self) {
                        reports.append(report)
                    }
                }
                completion(reports)
            }
        }
    }
    
    private func queryBlocks(for userId: String, completion: @escaping ([Block]?) -> Void) {
        let dbRef = Firestore.firestore()
        let blocksCollection = dbRef.collection("users").document(userId).collection("blocks")
        
        blocksCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error querying blocks: \(error)")
                completion(nil)
            } else {
                var blocks = [Block]()
                for document in querySnapshot!.documents {
                    if let block = try? document.data(as: Block.self) {
                        blocks.append(block)
                    }
                }
                completion(blocks) // 데이터를 외부로 전달
            }
        }
    }
    
    
    //    private func loadUsers() {
    //        var gender: [GenderType] = []
    //
    //        if HomeViewModel.filterGender.isEmpty {
    //            gender = GenderType.allCases
    //        } else {
    //            gender = HomeViewModel.filterGender
    //        }
    //
    //        DispatchQueue.global().async {
    //            let dbRef = Firestore.firestore()
    //            let query = dbRef.collection("users")
    //                .whereField("id", isNotEqualTo: self.loginUser.userId)
    //                .whereField("gender", in: gender.map { $0.rawValue })
    //
    //            query.getDocuments { (querySnapshot, error) in
    //                if let error = error {
    //                    print(error)
    //                } else {
    //                    var users = [User]()
    //                    for document in querySnapshot!.documents {
    //                        if let userData = document.data() as? [String: Any] {
    //                            if let mbtiRawValue = userData["mbti"] as? String,
    //                                let mbti = MBTIType(rawValue: mbtiRawValue),
    //                                let phoneNumber = userData["phoneNumber"] as? String,
    //                                let genderRawValue = userData["gender"] as? String,
    //                                let gender = GenderType(rawValue: genderRawValue),
    //                                let birth = userData["birth"] as? String,
    //                                let nickName = userData["nickName"] as? String,
    //                                let locationData = userData["location"] as? [String: Any],
    //                                let address = locationData["address"] as? String,
    //                                let latitude = locationData["latitude"] as? Double,
    //                                let longitude = locationData["longitude"] as? Double,
    //                                let imageURLs = userData["imageURLs"] as? [String],
    //                                let createdDate = userData["createdDate"] as? Double {
    //                                let location = Location(address: address, latitude: latitude, longitude: longitude)
    //
    //                                var subInfo: SubInfo?
    //                                if let subInfoData = userData["subInfo"] as? [String: Any] {
    //                                    let intro = subInfoData["intro"] as? String
    //                                    let height = subInfoData["height"] as? Int
    //                                    let drinkStatusRawValue = subInfoData["drinkStatus"] as? String
    //                                    let drinkStatus = FrequencyType(rawValue: drinkStatusRawValue ?? "")
    //                                    let smokeStatusRawValue = subInfoData["smokeStatus"] as? String
    //                                    let smokeStatus = FrequencyType(rawValue: smokeStatusRawValue ?? "")
    //                                    let religionRawValue = subInfoData["religion"] as? String
    //                                    let religion = ReligionType(rawValue: religionRawValue ?? "")
    //                                    let educationRawValue = subInfoData["education"] as? String
    //                                    let education = EducationType(rawValue: educationRawValue ?? "")
    //                                    let job = subInfoData["job"] as? String
    //                                    let hobbies = subInfoData["hobbies"] as? [String]
    //                                    let personalities = subInfoData["personalities"] as? [String]
    //
    //                                    var favoriteMBTIs: [MBTIType] = []
    //                                    if let favoriteMBTIsData = subInfoData["favoriteMBTIs"] as? [String] {
    //                                        favoriteMBTIs = favoriteMBTIsData.compactMap { MBTIType(rawValue: $0) }
    //                                    }
    //
    //                                    subInfo = SubInfo(intro: intro, height: height, drinkStatus: drinkStatus, smokeStatus: smokeStatus, religion: religion, education: education, job: job, hobbies: hobbies, personalities: personalities, favoriteMBTIs: favoriteMBTIs)
    //                                }
    //
    //
    //                                var reports: [Report]?
    //                                if let reportsData = userData["reports"] as? [[String: Any]] {
    //                                    reports = []
    //
    //                                    for reportData in reportsData {
    //                                        if let id = reportData["id"] as? String,
    //                                           let sendReportData = reportData["sendReport"] as? [[String: Any]],
    //                                           let recivedReportData = reportData["recivedReport"] as? [[String: Any]] {
    //                                            var sendReport: [Report.ReportInfo] = []
    //                                            var recivedReport: [Report.ReportInfo] = []
    //
    //                                            for sendReportDataItem in sendReportData {
    //                                                if let reportedUserId = sendReportDataItem["reportedUserId"] as? String,
    //                                                   let reason = sendReportDataItem["reason"] as? String,
    //                                                   let birth = sendReportDataItem["birth"] as? String,
    //                                                   let nickName = sendReportDataItem["nickName"] as? String,
    //                                                   let mbtiRawValue = sendReportDataItem["mbti"] as? String,
    //                                                   let imageURL = sendReportDataItem["imageURL"] as? String,
    //                                                   let createdDate = sendReportDataItem["createdDate"] as? Double {
    //                                                    let reportInfo = Report.ReportInfo(id: id, reportedUserId: reportedUserId, reason: reason, birth: birth, nickName: nickName, mbti: MBTIType(rawValue: mbtiRawValue) ?? .entp, imageURL: imageURL, createdDate: createdDate)
    //                                                    sendReport.append(reportInfo)
    //                                                }
    //                                            }
    //
    //                                            let report = Report(userId: id, sendReport: sendReport, recivedReport: recivedReport)
    //                                            reports?.append(report)
    //                                        }
    //                                    }
    //                                }
    //
    //                                var blocks: [Block]?
    //                                if let blocksData = userData["blocks"] as? [[String: Any]] {
    //                                    blocks = []
    //
    //                                    for blockData in blocksData {
    //                                        if let id = blockData["id"] as? String,
    //                                           let sendBlockData = blockData["sendBlock"] as? [[String: Any]],
    //                                           let recivedBlockData = blockData["recivedBlock"] as? [[String: Any]] {
    //                                            var sendBlock: [Block.BlockInfo] = []
    //                                            var recivedBlock: [Block.BlockInfo] = []
    //
    //                                            let block = Block(userId: id, sendBlock: sendBlock, recivedBlock: recivedBlock)
    //                                            blocks?.append(block)
    //                                        }
    //                                    }
    //                                }
    //
    //
    //                                let chuCount = userData["chuCount"] as? Int ?? 0
    //                                let isSubscribe = userData["isSubscribe"] as? Bool ?? false
    //
    //                                // Create a User object and add it to the users array
    //                                let user = User(id: document.documentID, mbti: mbti, phoneNumber: phoneNumber, gender: gender, birth: birth, nickName: nickName, location: location, imageURLs: imageURLs, createdDate: createdDate, subInfo: subInfo, reports: reports, blocks: blocks, chuCount: chuCount, isSubscribe: isSubscribe)
    //                                users.append(user)
    //                            }
    //                        }
    //                    }
    //                    self.otherUsers.accept(users)
    //                    print(users.count)
    //                }
    //            }
    //        }
    //    }
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
