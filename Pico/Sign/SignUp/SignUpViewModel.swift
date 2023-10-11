//
//  SignUpViewModel.swift
//  Pico
//
//  Created by LJh on 10/5/23.
//

import Foundation
import RxSwift
import RxRelay
import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

final class SignUpViewModel {
    
    private let dbRef = Firestore.firestore()
    static let shared: SignUpViewModel = SignUpViewModel()
    var imagesSubject: PublishSubject<[UIImage]> = PublishSubject()
    var urlStringsSubject: PublishSubject<[String]> = PublishSubject()
    var locationSubject: PublishSubject<Location> = PublishSubject()
    var isSaveSuccess: PublishSubject<Void> = PublishSubject()
    private let disposeBag = DisposeBag()
    var isRightUser: Bool = false
    var isRightName: Bool = false
    let id = UUID().uuidString
    var userMbti = ""
    lazy var mbti: MBTIType = {
        guard let mbtiType = MBTIType(rawValue: userMbti.lowercased()) else {
            return .enfj
        }
        return mbtiType
    }()
    var phoneNumber: String = ""
    var gender: GenderType = .etc
    var birth: String = ""
    var nickName: String = ""
    var location: Location = Location(address: "", latitude: 0, longitude: 0)
    var imageArray: [UIImage] = []
    var createdDate: Double = Date().timeIntervalSince1970
    var chuCount: Int = 0
    var isSubscribe: Bool = false
    
    lazy var newUser: User =
    User(id: id, mbti: mbti, phoneNumber: phoneNumber, gender: gender, birth: birth, nickName: nickName, location: location, imageURLs: [""], createdDate: createdDate, subInfo: nil, reports: nil, blocks: nil, chuCount: chuCount, isSubscribe: isSubscribe)
    
    private init() {
        locationSubject.subscribe { location in
            Loading.showLoading()
            self.newUser.location = location
            self.saveImage()
        }
        .disposed(by: disposeBag)
        
        imagesSubject
            .flatMap { images -> Observable<[String]> in
                return StorageService.shared.getUrlStrings(images: images, userId: self.id)
            }
            .subscribe(onNext: urlStringsSubject.onNext(_:))
            .disposed(by: disposeBag)
        
        urlStringsSubject
            .subscribe { strings in
                print("스트링 저장완료")
                self.newUser.imageURLs = strings
                self.saveNewUser()
                Loading.hideLoading()
            }.disposed(by: disposeBag)
    }
    
    func saveImage() {
        imagesSubject.onNext(imageArray)
    }
    
    func saveNewUser() {
        FirestoreService().saveDocumentRx(collectionId: .users, documentId: newUser.id, data: newUser)
            .subscribe(onNext: isSaveSuccess.onNext(_:))
            .disposed(by: disposeBag)
    }
   
    func sendSMS() {
        let urlString = "https://api.ncloud-docs.com/sens/sms"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("YOUR_ACCESS_KEY", forHTTPHeaderField: "X-NCP-APIGW-API-KEY-ID")
        request.setValue("YOUR_SECRET_KEY", forHTTPHeaderField: "X-NCP-APIGW-API-KEY")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "type": "sms",
            "from": "YOUR_PHONE_NUMBER",
            "to": ["RECIPIENT_PHONE_NUMBER"],
            "content": "Your verification code is: 123456"
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print("Error serializing JSON: \(error.localizedDescription)")
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    print("Response JSON: \(json ?? [:])")
                } catch let error {
                    print("Error parsing JSON: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
    }
 
    func loadCheckMessage() {
        
    }
    
    func checkPhoneNumber(userNumber: String, completion: @escaping () -> ()) {
        Loading.showLoading()
        self.dbRef.collection("users").whereField("phoneNumber", isEqualTo: userNumber).getDocuments { snapShot, err in
            guard err == nil, let documents = snapShot?.documents else {
                print(err ?? "서버오류 비상비상")
                self.isRightUser = false
                return
            }
            
            guard documents.first != nil else {
                self.isRightUser = true
                completion()
                return
            }
            self.isRightUser = false
            completion()
        }
    }
    
    func checkNickName(name: String, completion: @escaping () -> ()) {
        Loading.showLoading()
        self.dbRef.collection("users").whereField("nickName", isEqualTo: name).getDocuments { snapShot, err in
            guard err == nil, let documents = snapShot?.documents else {
                print(err ?? "서버오류 비상비상")
                self.isRightName = false
                return
            }
            
            guard documents.first != nil else {
                self.isRightName = true
                completion()
                return
            }
            self.isRightName = false
            completion()
        }
    }
}
