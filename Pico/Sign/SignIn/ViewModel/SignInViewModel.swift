//
//  SingInViewModel.swift
//  Pico
//
//  Created by LJh on 10/10/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class SignInViewModel {
    private let dbRef = Firestore.firestore()
    var loginUser: User?
    var isRightUser = false
    
    func signIn(userNumber: String, completion: @escaping (User?, String) -> ()) {
        let phoneNumberRegex = "^01[0-9]{1}-?[0-9]{3,4}-?[0-9]{4}$"
        let phoneNumberPredicate = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
        
        if !phoneNumberPredicate.evaluate(with: userNumber) {
            completion(nil, "유효하지 않은 전화번호 형식입니다.")
            return
        }
        Loading.showLoading()
        self.isRightUser = false
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.dbRef.collection("users").whereField("phoneNumber", isEqualTo: userNumber).getDocuments { snapShot, err in
                guard err == nil, let documents = snapShot?.documents else {
                    print(err ?? "서버오류 비상비상")
                    self.isRightUser = false
                    return
                }
                
                guard let document = documents.first else {
                    self.isRightUser = false
                    completion(nil, "일치하는 번호가 없습니다.")
                    return
                }
                let retrievedUser = self.convertDocumentToUser(document: document)
                
                self.isRightUser = true
                
                self.loginUser = retrievedUser
                completion(retrievedUser, "인증번호를 입력해주세요!")
            }
        }
    }
    
    func convertStop(document: QueryDocumentSnapshot) -> Stop {
        let data = document.data()
        let createdDate = data["createdDate"] as? Double ?? 0.0
        let during = data["during"] as? Int ?? 0
        let phoneNumber = data["phoneNumber"] as? String ?? ""
        let userData = data["user"] as? [String: Any] ?? [:]
        let mbti = MBTIType(rawValue: userData["mbti"] as? String ?? "") ?? .entp
        let gender = GenderType(rawValue: userData["gender"] as? String ?? "") ?? .etc
        let birth = userData["birth"] as? String ?? ""
        let nickName = userData["nickName"] as? String ?? ""
        let locationData = userData["location"] as? [String: Any] ?? [:]
        let address = locationData["address"] as? String ?? ""
        let latitude = locationData["latitude"] as? Double ?? 0.0
        let longitude = locationData["longitude"] as? Double ?? 0.0
        let imageURLs = userData["imageURLs"] as? [String] ?? []
        let chuCount = userData["chuCount"] as? Int ?? 0
        let isSubscribe = userData["isSubscribe"] as? Bool ?? false
        let user = User(mbti: mbti, phoneNumber: phoneNumber, gender: gender, birth: birth, nickName: nickName, location: Location(address: address, latitude: latitude, longitude: longitude), imageURLs: imageURLs, createdDate: createdDate, chuCount: chuCount, isSubscribe: isSubscribe)
        return Stop(createdDate: createdDate, during: during, phoneNumber: phoneNumber, user: user)
    }
  
    func convertDocumentToUser(document: QueryDocumentSnapshot) -> User {
        let data = document.data()
        let id = document.documentID
        let mbti = MBTIType(rawValue: data["mbti"] as? String ?? "") ?? .entp
        let phoneNumber = data["phoneNumber"] as? String ?? ""
        let gender = GenderType(rawValue: data["gender"] as? String ?? "") ?? .etc
        let birth = data["birth"] as? String ?? ""
        let nickName = data["nickName"] as? String ?? ""
        let locationData = data["location"] as? [String: Any] ?? [:]
        let address = locationData["address"] as? String ?? ""
        let latitude = locationData["latitude"] as? Double ?? 0.0
        let longitude = locationData["longitude"] as? Double ?? 0.0
        let imageURLs = data["imageURLs"] as? [String] ?? []
        let createdDate = data["createdDate"] as? Double ?? 0.0
        
        let subInfoData = data["subInfo"] as? [String: Any] ?? [:]
        let intro = subInfoData["intro"] as? String ?? ""
        let height = subInfoData["height"] as? Int ?? 0
        let drinkStatus = FrequencyType(rawValue: subInfoData["drinkStatus"] as? String ?? "") ?? .never
        let smokeStatus = FrequencyType(rawValue: subInfoData["smokeStatus"] as? String ?? "") ?? .never
        let religion = ReligionType(rawValue: subInfoData["religion"] as? String ?? "") ?? .etc
        let education = EducationType(rawValue: subInfoData["education"] as? String ?? "") ?? .middle
        let job = subInfoData["job"] as? String ?? ""
        let hobbies = subInfoData["hobbies"] as? [String] ?? []
        let personalities = subInfoData["personalities"] as? [String] ?? []
        let favoriteMBTIs = subInfoData["favoriteMBTIs"] as? [String] ?? []
        var mbtiArr: [MBTIType] = []
        favoriteMBTIs.forEach { mbti in
            mbtiArr.append(MBTIType(rawValue: mbti) ?? .enfp)
        }
        
        let subInfo = SubInfo(intro: intro, height: height, drinkStatus: drinkStatus, smokeStatus: smokeStatus, religion: religion, education: education, job: job, hobbies: hobbies, personalities: personalities, favoriteMBTIs: mbtiArr)

        let reports = data["reports"] as? Report ?? Report(userId: "")
        let blocks = data["blocks"] as? Block ?? Block(userId: "")
        let chuCount = data["chuCount"] as? Int ?? 0
        let isSubscribe = data["isSubscribe"] as? Bool ?? false
        
        let retrievedUser = User(id: id, mbti: mbti, phoneNumber: phoneNumber, gender: gender, birth: birth, nickName: nickName, location: Location(address: address, latitude: latitude, longitude: longitude), imageURLs: imageURLs, createdDate: createdDate, subInfo: subInfo, reports: [reports], blocks: [blocks], chuCount: chuCount, isSubscribe: isSubscribe)
        return retrievedUser
    }
}
