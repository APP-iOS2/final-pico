//
//  Font+Extensions.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit

extension UIFont {
    /// 제목 폰트사이즈
    static var picoTitleFont: UIFont {
        return UIFont.systemFont(ofSize: 22, weight: .bold)
    }
    /// 부제목 폰트사이즈
    static var picoSubTitleFont: UIFont {
        return UIFont.systemFont(ofSize: 18, weight: .semibold)
    }
    /// 제목에 대한 설명 폰트사이즈
    static var picoDescriptionFont: UIFont {
        return UIFont.systemFont(ofSize: 13)
    }
    /// 내용 폰트 사이즈
    static var picoContentFont: UIFont {
        return UIFont.systemFont(ofSize: 15)
    }
    /// 내용 굵은 폰트 사이즈
    static var picoContentBoldFont: UIFont {
        return UIFont.systemFont(ofSize: 15, weight: .semibold)
    }
    /// 버튼 폰트 사이즈
    static var picoButtonFont: UIFont {
        return UIFont.systemFont(ofSize: 15, weight: .bold)
    }
    /// mbti 라벨 폰트 사이트
    static var picoMBTILabelFont: UIFont {
        return UIFont.systemFont(ofSize: 22, weight: .bold)
    }
    /// mbti small 라벨 폰트 사이즈
    static var picoMBTISmallLabelFont: UIFont {
        return UIFont.systemFont(ofSize: 14, weight: .bold)
    }
    /// 로그인 뷰 MBTI 라벨 폰트 사이트 (40, medium)
    static var picoMBTISelectedLabelFont: UIFont {
        return UIFont.systemFont(ofSize: 40, weight: .medium)
    }
    /// 로그인 뷰 MBTI 설명 라벨 폰트 사이트 (40, medium)
    static var picoMBTISelectedSubLabelFont: UIFont {
        return UIFont.systemFont(ofSize: 13, weight: .thin)
    }
}
