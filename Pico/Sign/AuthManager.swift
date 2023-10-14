//
//  AuthManager.swift
//  Pico
//
//  Created by LJh on 10/13/23.
//
import Foundation
import CryptoKit

class AuthManager {
    // 네이버 클라우드 API에 접근하기 위한 키 및 서비스 ID와 발신자, 수신자 전화번호 설정
    let accessKey = "It6dUNEFLjbAFQsJ3ZTU" // 네이버 클라우드 Access Key
    let secretKey = "SEDWWDp225KhSCzC6c0C6D4fF20VqPsCQLKQxxU6" // 네이버 클라우드 Secret Key
    let serviceId = "ncp:sms:kr:312998324468:pico" // 네이버 클라우드 서비스 ID
    let senderPhoneNumber = "01095570253" // 발신자 전화번호
    let receiverPhoneNumber = "01094863904" // 수신자 전화번호 (SMS를 받을 사용자의 번호)
    
    // SMS 인증 메시지 전송 함수
    func sendVerificationCode() {
        // API 엔드포인트 URL 및 현재 타임스탬프 가져오기
        let apiUrl = "https://sens.apigw.ntruss.com/sms/v2/services/\(serviceId)/messages"
        let timestamp = String(Int(Date().timeIntervalSince1970))
        
        // 6자리 랜덤 숫자 생성
        let randomCode = configRandomCode()
        
        // SMS 메시지 내용 설정
        let message = """
        인증번호 테스트 입니다: \(randomCode)
        """
        
        // API 요청 바디를 JSON 형태로 구성
        let bodyDict: [String: Any] = [
            "type": "sms",
            "from": senderPhoneNumber,
            "to": [receiverPhoneNumber],
            "content": message
        ]
        
        // JSON 데이터로 바꿔서 HTTP 요청 바디에 설정
        guard let bodyData = try? JSONSerialization.data(withJSONObject: bodyDict) else {
            print("Error creating JSON data")
            return
        }
        
        // HMAC-SHA256 서명 생성
        let signature = configSignature(accessKey: accessKey, secretKey: secretKey, timestamp: timestamp, url: apiUrl, body: String(data: bodyData, encoding: .utf8) ?? "")
        
        // API 요청을 위한 URLRequest 생성 및 설정
        var request = URLRequest(url: URL(string: apiUrl)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(timestamp, forHTTPHeaderField: "x-ncp-apigw-timestamp")
        request.addValue(accessKey, forHTTPHeaderField: "x-ncp-iam-access-key")
        request.addValue(signature, forHTTPHeaderField: "x-ncp-apigw-signature-v2")
        request.httpBody = bodyData
        
        // URLSession을 이용한 API 호출
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            }
        }
        task.resume()  // URLSession 작업 시작
    }
    
    // 랜덤한 6자리 숫자 생성 함수
    func configRandomCode() -> String {
        let digits = "0123456789"
        var randomCode = ""
        for _ in 0..<6 {
            let randomIndex = Int.random(in: 0..<digits.count)
            let digit = digits[digits.index(digits.startIndex, offsetBy: randomIndex)]
            randomCode.append(digit)
        }
        return randomCode
    }
    
    // HMAC-SHA256 서명 생성 함수
    func configSignature(accessKey: String, secretKey: String, timestamp: String, url: String, body: String) -> String {
        // Secret Key를 SymmetricKey로 변환
        let signingKey = SymmetricKey(data: Data(secretKey.utf8))
        
        // 메시지 생성 (HTTP 메서드, URL, 타임스탬프, 바디)
        let message = "POST\n\(url)\n\(timestamp)\n\(body)"
        
        // HMAC-SHA256 서명 생성
        let signature = HMAC<SHA256>.authenticationCode(for: Data(message.utf8), using: signingKey)
        
        // 16진수 문자열로 변환하여 반환
        let signatureString = signature.map { String(format: "%02x", $0) }.joined()
        return signatureString
    }
    
}

// let authManager = AuthManager()
// authManager.sendVerificationCode()
