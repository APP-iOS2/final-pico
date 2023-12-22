//
//  CheckNickNameService.swift
//  Pico
//
//  Created by LJh on 10/18/23.
//
import Foundation
import RxSwift
import RxRelay
import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

final class CheckService {
    static let shared: CheckService = CheckService()
    
    private let dbRef = Firestore.firestore()
    
    func checkUserId(userId: String, completion: @escaping (_ isRight: Bool) -> ()) {
        Loading.showLoading(backgroundColor: .systemBackground.withAlphaComponent(0.8))
        DispatchQueue.global().async {
            self.dbRef.collection("users").whereField("id", isEqualTo: userId).getDocuments { snapShot, err in
                guard err != nil, let documents = snapShot?.documents else { return }
                
                if let document = documents.first {
                    if let user = try? document.data(as: User.self) {
                        UserDefaultsManager.shared.setUserData(userData: user)
                        completion(true)
                    } else {
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func checkPhoneNumber(userNumber: String, completion: @escaping (_ message: String, _ isRight: Bool) -> ()) {
        let regex = "^01[0-9]{1}-?[0-9]{3,4}-?[0-9]{4}$"
        let phoneNumberPredicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        if !phoneNumberPredicate.evaluate(with: userNumber) {
            completion("유효하지 않은 전화번호입니다.", false)
            return
        }
        
        Loading.showLoading()
        
        self.dbRef.collection(Collections.users.name).whereField("phoneNumber", isEqualTo: userNumber).getDocuments { snapShot, err in
            guard err == nil else {
                completion("서버에 문제가 있습니다.", false)
                return
            }
            
            guard let documents = snapShot?.documents, documents.first != nil else {
                completion("사용가능한 전화번호 입니다.", true)
                return
            }
            completion("이미 회원가입을 하셨어요!!", false)
        }
    }
    
    func checkNickName(name: String, completion: @escaping (_ message: String, _ isRight: Bool) -> ()) {
        do {
            let pattern = "([ㄱ-ㅎㅏ-ㅣ]){1,8}"
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: name, options: [], range: NSRange(location: 0, length: name.utf16.count))
            
            Loading.showLoading()
            
            if matches.isEmpty {
                self.dbRef.collection(Collections.users.name).whereField("nickName", isEqualTo: name).getDocuments { snapShot, err in
                    guard err == nil else {
                        print("checkNickName: \(String(describing: err))")
                        return
                    }
                    
                    guard let documents = snapShot?.documents, documents.first != nil else {
                        completion("사용가능한 닉네임이에요!", true)
                        return
                    }
                    completion("이미 사용 중인 닉네임이네요..", false)
                }
            } else {
                completion("연속된 자음 또는 모음이 포함되어 있어요! 제대로 지어주세요 😁", false)
                return
            }
        } catch {
            completion("정규식 에러: \(error)", false)
            return
        }
    }
    
    func checkBlockUser(userNumber: String, completion: @escaping (Bool) -> Void) {
        let regex = "^01[0-9]{1}-?[0-9]{3,4}-?[0-9]{4}$"
        let phoneNumberPredicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        if !phoneNumberPredicate.evaluate(with: userNumber) {
            completion(false)
            return
        }
        
        self.dbRef.collection(Collections.unsubscribe.name).whereField("phoneNumber", isEqualTo: userNumber).getDocuments { snapshot, error in
            guard error == nil, let documents = snapshot?.documents else {
                completion(false) // 에러 발생 또는 문서가 없음
                return
            }
            
            if !documents.isEmpty {
                completion(true) // 차단된 사용자임
            } else {
                completion(false) // 차단된 사용자가 아님
            }
        }
    }
    
    func checkStopUser(userNumber: String, completion: @escaping (Bool, Stop?) -> Void) {
        let regex = "^01[0-9]{1}-?[0-9]{3,4}-?[0-9]{4}$"
        let phoneNumberPredicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let tempStop = Stop(createdDate: 0, during: 0, phoneNumber: "", user: User.tempUser)
        if !phoneNumberPredicate.evaluate(with: userNumber) {
            completion(false, tempStop)
            return
        }
        
        FirestoreService.shared.searchDocumentWithEqualField(collectionId: .stop, field: "phoneNumber", compareWith: userNumber, dataType: Stop.self) { result in
            switch result {
            case .success(let data):
                if data.isEmpty {
                    completion(false, nil)
                } else {
                    completion(true, data.first)
                }
                
            case .failure(let err):
                print("checkStopUser: \(err)")
                completion(false, nil)
            }
        }
    }
    
    func checkOnline(userId: String, completion: @escaping (Bool) -> ()) {
        FirestoreService.shared.loadDocument(collectionId: .users, documentId: userId, dataType: User.self) { result in
            switch result {
            case .success(let user):
                completion(user?.isOnline ?? false)
                
            case .failure(let err):
                print("checkOnline: \(err)")
            }
        }
    }
    
    func updateOnline(userId: String, isOnline: Bool, completion: (() -> Void)? = nil) {
        FirestoreService.shared.updateDocument(collectionId: .users, documentId: userId, field: "isOnline", data: isOnline) { result in
            switch result {
            case .success:
                completion?()
                
            case .failure(let err):
                print("updateOnline: \(err)")
            }
        }
    }
}
