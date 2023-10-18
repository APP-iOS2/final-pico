//
//  SmsAuthManager.swift
//  Pico
//
//  Created by LJh on 10/15/23.
//
import Foundation
import CryptoKit

final class SmsAuthManager {
    let accessKey = "It6dUNEFLjbAFQsJ3ZTU"
    let secretKey = "SEDWWDp225KhSCzC6c0C6D4fF20VqPsCQLKQxxU6"
    let serviceId = "ncp:sms:kr:312998324468:pico"
    let senderPhoneNumber = "01095570253"
    let receiverPhoneNumber = "01094863904"
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
        let too: String // 린트때매 too 라고 함..
    }
    
    func sendVerificationCode() {
        let apiUrl = "https://sens.apigw.ntruss.com/sms/v2/services/\(serviceId)/messages"
        let timestamp = String(Int(Date().timeIntervalSince1970 * 1000))
        
        let randomCode = configRandomCode()
        let message = """
        인증번호 테스트: \(randomCode)
        """
       
        let bodyDict = encodeJson(type: "SMS", contentType: "COMM", countryCode: "82", from: senderPhoneNumber, content: "\(message)", too: receiverPhoneNumber)

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
        return randomCode
    }
    
    func checkRightCode(code: String) -> Bool {
        print(code)
        // MARK: - 이제 비교해야함
        return true
    }
    
    func encodeJson(type: String, contentType: String, countryCode: String, from: String, content: String, too: String) -> Data? {
        let tempSms = SMSMessage(type: type, contentType: contentType, countryCode: countryCode, from: from, content: content, messages: [Message(too: too)])

        do {
            let jsonData = try JSONEncoder().encode(tempSms)
            // 성공적으로 인코딩된 데이터를 사용할 수 있음
            return jsonData
        } catch {
            // 인코딩 중에 에러가 발생한 경우 에러 처리
            print("에러에러 비상비상: \(error)")
            return nil
        }
    }
    
    func configSignature(accessKey: String, secretKey: String, timestamp: String, url: String, body: String) -> String {
        let signingKey = SymmetricKey(data: Data(secretKey.utf8))
        let message = "POST\n\(url)\n\(timestamp)\n\(body)"
        let signature = HMAC<SHA256>.authenticationCode(for: Data(message.utf8), using: signingKey)
        let signatureString = signature.map { String(format: "%02x", $0) }.joined()
        print(signatureString)
        return signatureString
    }
}
