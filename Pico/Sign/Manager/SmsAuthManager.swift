//
//  SmsAuthManager.swift
//  Pico
//
//  Created by LJh on 10/15/23.
//
import Foundation
import CryptoKit

final class SmsAuthManager {
    
    private let accessKey = Bundle.main.accessKey
    private let secretKey = Bundle.main.secretKey
    private let serviceId = Bundle.main.serviceId
    private let senderPhoneNumber = Bundle.main.senderPhoneNumber
    private let receiverPhoneNumber = "01094863904"
    var smsCode = ""
    
    struct SMSMessage: Codable {
        let type: String
        let contentType: String
        let countryCode: String
        let from: String
        let content: String
        let messages: [Message]
    }

    struct Message: Codable {
        let to: String
        let content: String
    }
    // !!!: 멘토링 질문
    // 네이버 SMS API를 사용해서 문자인증을 구현하려고 하는데 API에서 원하는 형식으로 전달하는지 알고싶어요!
    // https://api.ncloud-docs.com/docs/ai-application-service-sens-smsv2#%EA%B8%B0%EB%B3%B8-%EC%A0%95%EB%B3%B4
    // 맞게 주었다고 생각하지만 Response: {"error":{"errorCode":"200","message":"Authentication Failed","details":"Invalid authentication information."}} 라는 response를 줍니다
    func sendVerificationCode() {
        let apiUrl = "https://sens.apigw.ntruss.com/sms/v2/services/\(serviceId)/messages"
        let timestamp = String(Int64(Date().timeIntervalSince1970 * 1000))
        
        let randomCode = configRandomCode()
        let message = """
        인증번호 테스트: \(randomCode)
        """
        
        let bodyDict = encodeJson(type: "SMS", contentType: "COMM", countryCode: "82", from: senderPhoneNumber, content: "\(message)", toUser: receiverPhoneNumber)

        guard let bodyData = bodyDict else {
            print("Error creating JSON data")
            return
        }
        
        let signature = configSignature(accessKey: accessKey, secretKey: secretKey, timestamp: timestamp, url: apiUrl, body: String(data: bodyData, encoding: .utf8) ?? "")
        
        var request = URLRequest(url: URL(string: apiUrl)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(timestamp, forHTTPHeaderField: "x-ncp-apigw-timestamp")
        request.addValue(accessKey, forHTTPHeaderField: "x-ncp-iam-access-key")
        request.addValue(signature, forHTTPHeaderField: "x-ncp-apigw-signature-v2")
        request.httpBody = bodyData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid HTTP response")
                    return
            }
                
            let statusCode = httpResponse.statusCode
            print("Status Code: \(statusCode)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            }
        }
        task.resume()
    }
    
    func configRandomCode() -> String {
        let digits = "0123456789"
        var randomCode = ""
        for _ in 0..<6 {
            let randomIndex = Int.random(in: 0..<digits.count)
            let digit = digits[digits.index(digits.startIndex, offsetBy: randomIndex)]
            randomCode.append(digit)
        }
        smsCode = randomCode
        print("인증번호 생성: \(smsCode)")
        return randomCode
    }
    
    func checkRightCode(code: String) -> Bool {
        print(code)
        // MARK: - 이제 비교해야함
        return true
    }
    
    func encodeJson(type: String, contentType: String, countryCode: String, from: String, content: String, toUser: String) -> Data? {
        let tempSms = SMSMessage(type: type, contentType: contentType, countryCode: countryCode, from: from, content: content, messages: [Message(to: toUser, content: "api 테스트")])
        do {
            let jsonData = try JSONEncoder().encode(tempSms)
            return jsonData
        } catch {
            print("에러에러 비상비상: \(error)")
            return nil
        }
    }
    
    func configSignature(accessKey: String, secretKey: String, timestamp: String, url: String, body: String) -> String {
            let signingKey = SymmetricKey(data: Data(secretKey.utf8))
            let message = "POST\n\(url)\n\(timestamp)\n\(body)"
            let signatureData = HMAC<SHA256>.authenticationCode(for: Data(message.utf8), using: signingKey)
            let base64EncodedSignature = Data(signatureData).base64EncodedString()
            return base64EncodedSignature
        }
}
