//
//  UserDetailViewModel.swift
//  Pico
//
//  Created by 신희권 on 2023/09/27.
//

import Foundation
import FirebaseFirestore
import RxSwift
import RxRelay

final class UserDetailViewModel {
    let userObservable = PublishSubject<User>()
    private let disposeBag = DisposeBag()
    private let dbRef = Firestore.firestore()
    
    init(user: User) {
        loadUserTest(user: user)
    }
    
    func loadUserTest(user: User) {
        DispatchQueue.global().async {
            self.dbRef.collection("users").whereField("id", isEqualTo: "01B118D9-4626-46F3-96D8-6D4229DACFDD").getDocuments { snapShot, err in
                guard err == nil, let documents = snapShot?.documents else {
                    print(err ?? "서버오류 비상비상")
                    return
                }
                
                guard let document = documents.first else {
                    return
                }
                
                let data = document.data()
                let id = document.documentID
                let mbti = data["mbti"] as? MBTIType ?? .enfj
                let phoneNumber = data["phoneNumber"] as? String ?? ""
                let gender = data["gender"] as? GenderType ?? .etc
                let birth = data["birth"] as? String ?? ""
                let nickName = data["nickName"] as? String ?? ""
                let location = data["location"] as? Location ?? Location(address: "aasd", latitude: 0.0, longitude: 0.0)
                let imageURLs = data["imageURLs"] as? [String] ?? []
                let createdDate = data["createdDate"] as? Double ?? 0.0
                
                // TODO: - subInfo, reports, blocks nil 값 들어 갈 수 있게 변경
                let subInfo = data["subInfo"] as? SubInfo ?? SubInfo(intro: "인트로 입니당.", height: 180, drinkStatus: .never, smokeStatus: .never, religion: .buddhism, education: .college, job: "", hobbies: ["asdasd"], personalities: ["asds"], favoriteMBTIs: [.enfj])
                let reports = data["reports"] as? Report ?? Report(id: id, reportedId: "", reason: "", reportedDate: 0)
                let blocks = data["blocks"] as? Block ?? Block(id: id, blockedId: "", blockedDate: 0)
                let chuCount = data["chuCount"] as? Int ?? 0
                let isSubscribe = data["isSubscribe"] as? Bool ?? false
                let newUser = User(id: id, mbti: mbti, phoneNumber: phoneNumber, gender: gender, birth: birth, nickName: nickName, location: location, imageURLs: imageURLs, createdDate: createdDate, subInfo: subInfo, reports: [reports], blocks: [blocks], chuCount: chuCount, isSubscribe: isSubscribe)
                
                self.userObservable.onNext(newUser)
            }
        }
    }
    
    func loadUser() {
        FirestoreService.shared.loadDocumentRx(collectionId: .users, documentId: "12066FD9-5F5E-4F62-9F7B-FFF1113E8FCD", dataType: User.self)
            .compactMap { $0 }
            .bind(to: userObservable)
            .disposed(by: disposeBag)
    }
    
    // document 에 들어가는 ID만 수정
    func reportUser(report: Report, completion: @escaping () -> () ) {
       
        DispatchQueue.global().async {
            self.dbRef.collection("users").document("01B118D9-4626-46F3-96D8-6D4229DACFDD").updateData([
                "reports": FieldValue.arrayUnion([report.asDictionary()])
            ])
            print("Success to save new document at users \(report.reportedId)")
        }
        completion()
    }
    // document 에 들어가는 ID만 수정
    func blockUser(block: Block, completion: @escaping () -> () ) {
        let dbRef = Firestore.firestore()
        DispatchQueue.global().async {
            self.dbRef.collection("users").document("01B118D9-4626-46F3-96D8-6D4229DACFDD").updateData([
                "blocks": FieldValue.arrayUnion([block.asDictionary()])
            ])
            print("Success to save new document at users \(block)")
        }
        completion()
    }
}
