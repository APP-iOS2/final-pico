//
//  EmailAuthService.swift
//  Pico
//
//  Created by 최하늘 on 2/8/24.
//

import Foundation
import SwiftSMTP

final class EmailAuthService {
    static let shared: EmailAuthService = EmailAuthService()
    
    private let senderEmail = Bundle.main.senderEmail
    private var randomNumber = ""
    
    func sendVerificationCode(phoneNumber: String, email: String, completion: @escaping (Bool) -> ()) {
        guard phoneNumber != Bundle.main.testPhoneNumber else {
            randomNumber = Bundle.main.testAuthNum
            return
        }
        
        let subject = "피코 PICO 이메일 인증 안내"
        let content = """
                            인증 코드를 발급해드립니다.
                            인증번호는 "\(configRandomNumber())" 입니다.
                            
                            해당 인증코드를 입력해주세요.
                            타인에게 절대 알려주지 마세요.
                        """
        
        let smtp = SMTP(
            hostname: "smtp.gmail.com",
            email: senderEmail,
            password: ""
        )
        
        let mail_from = Mail.User(name: "피코 PICO", email: senderEmail)
        let mail_to = Mail.User(name: "사용자", email: email)
        
        let mail = Mail(
            from: mail_from,
            to: [mail_to],
            subject: subject,
            text: content)
        
        DispatchQueue.global().async {
            smtp.send(mail) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("\(error), \(error.localizedDescription)")
                        completion(false)
                        return
                    }
                    completion(true)
                }
            }
        }
    }
    
    func checkRandomNumber(number: String) -> Bool {
        if randomNumber == number {
            return true
        }
        return false
    }
    
    private func configRandomNumber() -> String {
        let str = (0..<6).map { _ in "0123456789".randomElement()! }
        
        randomNumber = String(str)
        return String(str)
    }
}
