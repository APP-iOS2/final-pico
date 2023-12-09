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
                
                let data = document.data()
                let id = document.documentID
                let mbti = data["mbti"] as? MBTIType ?? .enfj
                let phoneNumber = data["phoneNumber"] as? String ?? ""
                let gender = data["gender"] as? GenderType ?? .etc
                let birth = data["birth"] as? String ?? ""
                let nickName = data["nickName"] as? String ?? ""
                let locationData = data["location"] as? [String: Any]
                guard let address = locationData?["address"] as? String,
                      let latitude = locationData?["latitude"] as? Double,
                      let longitude = locationData?["longitude"] as? Double else { return }
                let imageURLs = data["imageURLs"] as? [String] ?? []
                let createdDate = data["createdDate"] as? Double ?? 0.0
                let subInfo = data["subInfo"] as? SubInfo ?? SubInfo(intro: "", height: 0, drinkStatus: .never, smokeStatus: .never, religion: .buddhism, education: .college, job: "", hobbies: [""], personalities: [""], favoriteMBTIs: [.enfj])
                let reports = data["reports"] as? Report ?? Report(userId: "")
                let blocks = data["blocks"] as? Block ?? Block(userId: "")
                let chuCount = data["chuCount"] as? Int ?? 0
                let isSubscribe = data["isSubscribe"] as? Bool ?? false
                let retrievedUser = User(id: id, mbti: mbti, phoneNumber: phoneNumber, gender: gender, birth: birth, nickName: nickName, location: Location(address: address, latitude: latitude, longitude: longitude), imageURLs: imageURLs, createdDate: createdDate, subInfo: subInfo, reports: [reports], blocks: [blocks], chuCount: chuCount, isSubscribe: isSubscribe)
                self.isRightUser = true
                
                self.loginUser = retrievedUser
                completion(retrievedUser, "인증번호를 입력해주세요!")
            }
        }
    }
}
