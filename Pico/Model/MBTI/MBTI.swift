//
//  MBTI.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/26.
//

import Foundation

enum MBTIType: String, Codable, CaseIterable {
    case enfj
    case entj
    case enfp
    case entp
    case esfp
    case esfj
    case estp
    case estj
    case infp
    case infj
    case intp
    case istp
    case isfp
    case isfj
    case istj
    case intj
    
    var nameString: String {
        return self.rawValue.uppercased()
    }
    
    var colorName: String {
        switch self {
        case .enfj:
            return "#A0CDE5"
        case .entj:
            return "#A0E5BC"
        case .enfp:
            return "#C3A0E5"
        case .entp:
            return "#E4A0E5"
        case .esfp:
            return "#EFB495"
        case .esfj:
            return "#E4E5A0"
        case .estp:
            return "#A0E5D4"
        case .estj:
            return "#B5D5C5"
        case .infp:
            return "#FF9B9B"
        case .infj:
            return "#007CBE"
        case .intp:
            return "#116A7B"
        case .istp:
            return "#E5B1A0"
        case .isfp:
            return "#FFD966"
        case .isfj:
            return "#DA6969"
        case .istj:
            return "#EF9595"
        case .intj:
            return "#7C96AB"
        }
    }
}
