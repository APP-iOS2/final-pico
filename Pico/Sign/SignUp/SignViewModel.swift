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

final class SignViewModel {
    static let shared: SignViewModel = SignViewModel()
    private let disposeBag = DisposeBag()
    let id = UUID().uuidString
    var userMbti = ""
    var phoneNumber: String = ""
    var gender: GenderType = .etc
    var birth: String = ""
    var nickName: String = ""
    var location: Location = Location(address: "", latitude: 0, longitude: 0)
    var imageArray: [UIImage] = []
    var imagesSubject: PublishSubject<[UIImage]> = PublishSubject()
    var urlStringsSubject: PublishSubject<[String]> = PublishSubject()
    var locationSubject: PublishSubject<Location> = PublishSubject()
    
    private init() {
        locationSubject.subscribe { location in
            self.newUser.location = location
            
            self.startSave()
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
            }.disposed(by: disposeBag)
        
    }
    
    func startSave() {
        imagesSubject.onNext(imageArray)
    }
    
    var createdDate: Double = 0
    var chuCount: Int = 0
    var isSubscribe: Bool = false
    var isSaveSuccess: PublishSubject<Void> = PublishSubject()
    
    lazy var newUser: User =
    User(id: id, mbti: .entp, phoneNumber: phoneNumber, gender: gender, birth: birth, nickName: nickName, location: location, imageURLs: [""], createdDate: createdDate, subInfo: nil, reports: nil, blocks: nil, chuCount: chuCount, isSubscribe: isSubscribe)
    
    func saveNewUser() {
        FirestoreService().saveDocumentRx(collectionId: .users, documentId: newUser.id, data: newUser)
            .subscribe(onNext: isSaveSuccess.onNext(_:))
            .disposed(by: disposeBag)
    }
}
