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
            guard let self else { return }
            
            dbRef.collection("users").whereField("phoneNumber", isEqualTo: userNumber).getDocuments {  [weak self] snapShot, err in
                guard let self else { return }
                
                guard err == nil, let documents = snapShot?.documents else {
                    print(err ?? "서버오류 비상비상")
                    isRightUser = false
                    return
                }
                
                guard let document = documents.first else {
                    isRightUser = false
                    completion(nil, "일치하는 번호가 없습니다.")
                    return
                }
                
                guard let retrievedUser = try? document.data(as: User.self) else {
                    isRightUser = false
                    completion(nil, "데이터 형식이 다름.")
                    return
                }
                
                isRightUser = true
                loginUser = retrievedUser
                completion(retrievedUser, "인증번호를 입력해주세요!")
            }
        }
    }
}
