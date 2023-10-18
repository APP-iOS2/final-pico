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
    private let dbRef = Firestore.firestore()
    
    func checkPhoneNumber(userNumber: String, completion: @escaping (_ message: String, _ isRight: Bool) -> ()) {
        let regex = "^01[0-9]{1}-?[0-9]{3,4}-?[0-9]{4}$"
        let phoneNumberPredicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        if !phoneNumberPredicate.evaluate(with: userNumber) {
            completion("유효하지 않은 전화번호입니다..", false)
            return
        }
        
        SignLoadingManager.showLoading(text: "중복된 번호를 찾고 있어요!")
        
        self.dbRef.collection("users")
            .whereField("phoneNumber", isEqualTo: userNumber)
            .getDocuments { snapShot, err in
                guard err == nil, let documents = snapShot?.documents else {
                    completion("서버오류 비상비상", false)
                    return
                }
                
                guard documents.first != nil else {
                    completion("사용가능한 전화번호 입니다.", true)
                    return
                }
                completion("이미 회원가입을 하셨어요!!", false)
        }
    }
    
    func checkNickName(name: String, completion: @escaping (_ message: String, _ isRight: Bool) -> ()) {
        SignLoadingManager.showLoading(text: "중복된 닉네임을 찾고 있어요!")
        
        do {
            let pattern = "([ㄱ-ㅎㅏ-ㅣ]){2,8}"
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: name, options: [], range: NSRange(location: 0, length: name.utf16.count))
            
            if matches.isEmpty {
                self.dbRef
                    .collection("users").whereField("nickName", isEqualTo: name)
                    .getDocuments { [weak self] snapShot, err in
                    guard let self = self else { return }
                    guard err == nil, let documents = snapShot?.documents else {
                        print(err ?? "서버오류 비상비상")
                        return
                    }
                    
                    guard documents.first != nil else {
                        completion("사용가능한 닉네임이에요!!", true)
                        return
                    }
                    completion("이미 포함된 닉네임이네요..", false)
                    
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
}
