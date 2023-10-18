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
    
    func signIn(userNumber: String, completion: @escaping (User?) -> ()) {
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
                    print("번호와 맞는게 없는걸?")
                    self.isRightUser = false
                    completion(nil)
                    return
                }
                
                let data = document.data()
                let id = document.documentID
                let mbti = data["mbti"] as? MBTIType ?? .enfj
                let phoneNumber = data["phoneNumber"] as? String ?? ""
                let gender = data["gender"] as? GenderType ?? .etc
                let birth = data["birth"] as? String ?? ""
                let nickName = data["nickName"] as? String ?? ""
                let location = data["location"] as? Location ?? Location(address: "", latitude: 0.0, longitude: 0.0)
                let imageURLs = data["imageURLs"] as? [String] ?? []
                let createdDate = data["createdDate"] as? Double ?? 0.0
                let subInfo = data["subInfo"] as? SubInfo ?? SubInfo(intro: "", height: 0, drinkStatus: .never, smokeStatus: .never, religion: .buddhism, education: .college, job: "", hobbies: [""], personalities: [""], favoriteMBTIs: [.enfj])
                let reports = data["reports"] as? Report ?? Report(userId: "")
                let blocks = data["blocks"] as? Block ?? Block(userId: "")
                let chuCount = data["chuCount"] as? Int ?? 0
                let isSubscribe = data["isSubscribe"] as? Bool ?? false
                let retrievedUser = User(id: id, mbti: mbti, phoneNumber: phoneNumber, gender: gender, birth: birth, nickName: nickName, location: location, imageURLs: imageURLs, createdDate: createdDate, subInfo: subInfo, reports: [reports], blocks: [blocks], chuCount: chuCount, isSubscribe: isSubscribe)
                self.isRightUser = true
                
                self.loginUser = retrievedUser
                completion(retrievedUser)
            }
        }
    }
}
