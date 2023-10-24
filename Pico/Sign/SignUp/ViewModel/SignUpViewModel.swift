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
    
    var isRightPhoneNumber: Bool = false
    var isRightName: Bool = false
    private let id = UUID().uuidString
    var userMbti = ""
    private lazy var mbti: MBTIType = {
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
    var progressStatus: Float = 0.0
    
    private lazy var newUser: User =
    User(id: id, mbti: mbti, phoneNumber: phoneNumber, gender: gender, birth: birth, nickName: nickName, location: location, imageURLs: [""], createdDate: createdDate, subInfo: nil, reports: nil, blocks: nil, chuCount: chuCount, isSubscribe: isSubscribe)
    
    
    init() {
        locationSubject.subscribe { [weak self] location in
            guard let self = self else { return }
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
            .subscribe { [weak self] strings in
                guard let self = self else { return }
                print("스트링 저장완료")
                self.newUser.imageURLs = strings
                self.saveNewUser()
                Loading.hideLoading()
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
}
