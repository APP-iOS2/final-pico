//
//  UIColor+Extensions.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit

extension UIColor {
    convenience init(hex: String, alpha: Double = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /// 메인 블루 색상
    static let picoBlue: UIColor = UIColor(hex: "#727EED")
    
    /// 투명도 70% 적용된 메인 블루 색상
    static let picoAlphaBlue: UIColor = UIColor(hex: "#727EED", alpha: 0.7)
    
    /// 투명도 24% 적용된 메인 블루 색상
    static let picoBetaBlue: UIColor = UIColor(hex: "#727EED", alpha: 0.24)
    
    /// 메인 그레이 색상
    static let picoGray: UIColor = UIColor(hex: "#E3E3E3")
    
    /// 투명도 80% 적용된 화이트 색상
    static let picoAlphaWhite: UIColor = .white.withAlphaComponent(0.8)
    
    /// 테이블뷰 백그라운드 색상
    static let picoLightGray: UIColor = UIColor(hex: "#F1F1F1")
    
    /// 그라이데이션 중간 색상
    static let picoGradientMedium: UIColor = UIColor(hex: "#A07BEE")
    
    /// 그라이데이션 중간2 색상
    static let picoGradientMedium2: UIColor = UIColor(hex: "#B58FF4")
    
    /// 그라이데이션 마지막 색상
    static let picoGradientLast: UIColor = UIColor(hex: "#DFB7FF")
    
    /// 폰트 블랙 색상
    static let picoFontBlack: UIColor = .label
    
    /// 폰트 그레이 색상
    static let picoFontGray: UIColor = .secondaryLabel
    
    /// 별 옐로우 색상
    static let picoStarYellow: UIColor = UIColor(hex: "#FFEB84")
}
