//
//  SMSAuthService.swift
//  Pico
//
//  Created by LJh on 10/15/23.
//
import Foundation
import CommonCrypto

final class SMSAuthService {
    enum SMSRequestType: String {
        case sms
        case lms
        case mms
        
        var name: String {
            return self.rawValue.uppercased()
        }
    }
    
    struct SMSRequest: Codable {
        let type: String // (SMS | LMS | MMS)
        /// 발신번호
        let from: String
        /// 기본 메시지 제목
        let subject: String?
        /// 기본 메시지 내용
        let content: String
        /// 메시지 정보
        let messages: [Message]
        let files: [File]
    }
    
    struct Message: Codable {
        /// 수신번호
        let to: String
    }
    
    struct File: Codable {
        let fileId: String?
    }
    
    private let accessKey = Bundle.main.accessKey
    private let secretKey = Bundle.main.secretKey
    private let serviceId = Bundle.main.serviceId
    private let senderPhoneNumber = Bundle.main.senderPhoneNumber
    private var randomNumber = ""
    private let method = "POST"
    private let timestamp = String(Int(Date().timeIntervalSince1970 * 1000))
    
    func sendVerificationCode(phoneNumber: String) {
        guard phoneNumber != Bundle.main.testPhoneNumber else {
            randomNumber = Bundle.main.testAuthNum
            return
        }
        
        let urlString = "https://sens.apigw.ntruss.com/sms/v2/services/\(serviceId)/messages"
        let signature = makeSignature()
        
        let randomCode = configRandomCode()
        let message = """
            PICO 인증번호: \(randomCode)
            """
        let number = phoneNumber.replacingOccurrences(of: "-", with: "")
        
        let smsRequest = SMSRequest(type: SMSRequestType.sms.name,
                                    from: senderPhoneNumber,
                                    subject: "PICO 인증번호 발송",
                                    content: message,
                                    messages: [Message(to: number)],
                                    files: [])
        let bodyDict = smsRequest.asDictionary()
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(accessKey, forHTTPHeaderField: "x-ncp-iam-access-key")
        request.setValue(timestamp, forHTTPHeaderField: "x-ncp-apigw-timestamp")
        request.setValue(signature, forHTTPHeaderField: "x-ncp-apigw-signature-v2")
        request.httpBody = try? JSONSerialization.data(withJSONObject: bodyDict, options: [.prettyPrinted])
        
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
    
    func checkRightCode(code: String) -> Bool {
        if randomNumber == code {
            return true
        } else {
            return false
        }
    }
    
    private func configRandomCode() -> String {
        let digits = "0123456789"
        var randomCode = ""
        for _ in 0..<6 {
            let randomIndex = Int.random(in: 0..<digits.count)
            let digit = digits[digits.index(digits.startIndex, offsetBy: randomIndex)]
            randomCode.append(digit)
        }
        print("인증번호 생성: \(randomCode)")
        randomNumber = randomCode
        return randomCode
    }
    
    private func makeSignature() -> String {
        let url = "/sms/v2/services/\(serviceId)/messages"
        let message = method + " " + url + "\n" + timestamp + "\n" + accessKey
        let keyData = secretKey.data(using: .utf8)!
        var macOut = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        keyData.withUnsafeBytes { keyBytes in
            CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), keyBytes.baseAddress, keyData.count, message, message.utf8.count, &macOut)
        }
        
        let hmacData = Data(bytes: macOut, count: Int(CC_SHA256_DIGEST_LENGTH))
        let base64Encoded = hmacData.base64EncodedString()
        
        return base64Encoded
    }
}
