//
//  UIFont+Extensions.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit

extension UIFont {
    /// 제목 폰트사이즈 (22, bold)
    static var picoTitleFont: UIFont {
        return UIFont.systemFont(ofSize: 22, weight: .bold)
    }
    /// 부제목 폰트사이즈 (18, semibold)
    static var picoSubTitleFont: UIFont {
        return UIFont.systemFont(ofSize: 18, weight: .semibold)
    }
    /// 부제목 폰트사이즈 (16, semibold)
    static var picoSubTitleSmallFont: UIFont {
        return UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
    /// 제목에 대한 설명 폰트사이즈 (13, regular)
    static var picoDescriptionFont: UIFont {
        return UIFont.systemFont(ofSize: 13)
    }
    /// 내용 폰트 사이즈 (15, regular)
    static var picoContentFont: UIFont {
        return UIFont.systemFont(ofSize: 15)
    }
    /// 내용 굵은 폰트 사이즈 (15, semibold)
    static var picoContentBoldFont: UIFont {
        return UIFont.systemFont(ofSize: 15, weight: .semibold)
    }
    /// 버튼 폰트 사이즈 (15, bold)
    static var picoButtonFont: UIFont {
        return UIFont.systemFont(ofSize: 15, weight: .bold)
    }
    /// mbti 라벨 폰트 사이트 (22, bold)
    static var picoMBTILabelFont: UIFont {
        return UIFont.systemFont(ofSize: 22, weight: .bold)
    }
    /// mbti small 라벨 폰트 사이즈 (14, bold)
    static var picoMBTISmallLabelFont: UIFont {
        return UIFont.systemFont(ofSize: 14, weight: .bold)
    }
    /// 로그인 뷰 MBTI 라벨 폰트 사이트 (40, medium)
    static var picoMBTISelectedLabelFont: UIFont {
        return UIFont.systemFont(ofSize: 40, weight: .medium)
    }
    /// 로그인 뷰 MBTI 설명 라벨 폰트 사이트 (13, thin)
    static var picoMBTISelectedSubLabelFont: UIFont {
        return UIFont.systemFont(ofSize: 13, weight: .thin)
    }
    /// 프로필 라벨 폰트 사이즈 (14, regular)
    static var picoProfileLabelFont: UIFont {
        return UIFont.systemFont(ofSize: 14)
    }
    /// 프로필 이름 폰트 사이즈 (25, medium)
    static var picoProfileNameFont: UIFont {
        return UIFont.systemFont(ofSize: 25, weight: .medium)
    }
}
