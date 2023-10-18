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
    
    var progressStatus: Float = 0.0
    
    init() {
        locationSubject.subscribe { location in
            SignLoadingManager.showLoading(text: "위치정보를 받는중이에요!!")
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
                SignLoadingManager.hideLoading()
            }.disposed(by: disposeBag)
    }
    
    func animateProgressBar(progressView: UIProgressView, endPoint: Float) {
        let endStatus = endPoint * 0.143
        UIView.animate(withDuration: 3) {
            progressView.setProgress(endStatus, animated: true)
        }
        progressStatus = endStatus
    }

    func saveImage() {
        imagesSubject.onNext(imageArray)
    }
    
    func saveNewUser() {
        FirestoreService().saveDocumentRx(collectionId: .users, documentId: newUser.id, data: newUser)
            .subscribe(onNext: isSaveSuccess.onNext(_:))
            .disposed(by: disposeBag)
    }
    
    func checkPhoneNumber(userNumber: String, completion: @escaping () -> ()) {
        SignLoadingManager.showLoading(text: "중복된 번호를 찾고 있어요!")
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
    
    func checkNickName(name: String, completion: @escaping (_ message: String) -> ()) {
        SignLoadingManager.showLoading(text: "중복된 닉네임을 찾고 있어요!")
        
        do {
            let pattern = "([ㄱ-ㅎㅏ-ㅣ]){2,}"
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: name, options: [], range: NSRange(location: 0, length: name.utf16.count))
            
            if matches.isEmpty {
                self.dbRef.collection("users").whereField("nickName", isEqualTo: name).getDocuments { snapShot, err in
                    guard err == nil, let documents = snapShot?.documents else {
                        print(err ?? "서버오류 비상비상")
                        self.isRightName = false
                        return
                    }
                    
                    guard documents.first != nil else {
                        self.isRightName = true
                        completion("굳 ")
                        return
                    }
                    self.isRightName = false
                    completion("이미 포함된 닉네임")
                }
            } else {
                self.isRightName = false
                completion("연속된 자음 또는 모음이 포함되어 있습니다.")
                return
            }
        } catch {
            self.isRightName = false
            completion("정규식 에러: \(error)")
            return
        }
    }
}
