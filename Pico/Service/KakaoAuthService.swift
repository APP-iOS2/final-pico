//
//  KakaoAuthService.swift
//  Pico
//
//  Created by 최하늘 on 2/20/24.
//

import Foundation
import KakaoSDKCommon
import KakaoSDKTemplate
import KakaoSDKShare

enum KakaoLinkType {
    case app(url: URL)
    case web(url: URL)
    case err
}

final class KakaoAuthService {
    static let shared: KakaoAuthService = KakaoAuthService()
    
    private var randomNumber = ""
    
    func sendVerificationCode(phoneNumber: String, completion: @escaping (KakaoLinkType) -> ()) {
        guard phoneNumber != Bundle.main.testPhoneNumber else {
            randomNumber = Bundle.main.testAuthNum
            return
        }
        
        DispatchQueue.global().async {
            self.kakaoAuth { kakaoLinkType in
                completion(kakaoLinkType)
            }
        }
    }
    
    func checkRandomNumber(number: String) -> Bool {
        return randomNumber == number ? true : false
    }
    
    private func configRandomNumber() -> String {
        let str = (0..<6).map { _ in "0123456789".randomElement()! }
        
        randomNumber = String(str)
        return String(str)
    }
    
    private func kakaoAuth(completion: @escaping (KakaoLinkType) -> ()) {
        let link = Link(mobileWebUrl: URL(string: "https://developers.kakao.com"))
        let appLink = Link(androidExecutionParams: ["key1": "value1", "key2": "value2"],
                           iosExecutionParams: ["key1": "value1", "key2": "value2"])
        
        let appButton = Button(title: "앱으로 보기", link: appLink)
        
        guard let imageUrl = URL(string: Defaults.logoImageURLString) else { return }
        let content = Content(title: """
                                    인증번호는 "\(configRandomNumber())" 입니다. \n
                                    해당 인증코드를 입력해주세요.
                                    타인에게 절대 알려주지 마세요.
                                    """,
                              imageUrl: imageUrl,
                              imageHeight: 50,
                              link: link)
        
        let template = FeedTemplate(content: content, buttons: [appButton])
        
        if let templateJsonData = (try? SdkJSONEncoder.custom.encode(template)) {
            if let templateJsonObject = SdkUtils.toJsonObject(templateJsonData) {
                if ShareApi.isKakaoTalkSharingAvailable() {
                    ShareApi.shared.shareDefault(templateObject: templateJsonObject) {(linkResult, error) in
                        if let error = error {
                            print("error : \(error)")
                            completion(.err)
                        } else {
                            print("defaultLink(templateObject:templateJsonObject) success.")
                            guard let linkResult = linkResult else { return }
                            completion(.app(url: linkResult.url))
                        }
                    }
                    
                } else {
                    print("카카오톡 미설치")
                    if let url = ShareApi.shared.makeDefaultUrl(templateObject: templateJsonObject) {
                        completion(.web(url: url))
                    }
                }
            }
        }
    }
}
