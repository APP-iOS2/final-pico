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
        return UIFont.systemFont(ofSize: 24, weight: .bold)
    }
    /// 부제목 폰트사이즈
    static var picoSubTitleFont: UIFont {
        return UIFont.systemFont(ofSize: 18, weight: .semibold)
    }
    /// 제목에 대한 설명 폰트사이즈
    static var picoDescriptionFont: UIFont {
        return UIFont.systemFont(ofSize: 13)
    }
    /// 버튼 폰트 사이트
    static var picoButtonFont: UIFont {
        return UIFont.systemFont(ofSize: 18, weight: .bold)
    }
    /// mbti 라벨 폰트 사이트
    static var picoMBTILabelFont: UIFont {
        return UIFont.systemFont(ofSize: 22, weight: .bold)
    }
}
