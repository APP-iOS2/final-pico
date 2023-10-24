//
//  MBTIManager.swift
//  Pico
//
//  Created by 임대진 on 10/18/23.
//

import Foundation

struct MBTIManager {
    
    func get(mbti1: MBTIType, mbti2: MBTIType) -> CompatibilityType {
        return compatibilityDictionary[mbti1]?[mbti2] ?? .best
    }
    
    enum CompatibilityType: String {
        case best, good, nomal, soso, bad
        
        var information: String {
            switch self {
            case .best:
                return "정말 잘맞아요 !"
            case .good:
                return "좋은 관계가 될 수 있어요"
            case .nomal:
                return "무난한 관계에요"
            case .soso:
                return "서로 관심이 필요해요"
            case .bad:
                return "서로가 노력해야 해요"
            }
        }
        
        var star: Int {
            switch self {
            case .best:
                return 5
            case .good:
                return 4
            case .nomal:
                return 3
            case .soso:
                return 2
            case .bad:
                return 1
            }
        }
    }
    
    let compatibilityDictionary: [MBTIType: [MBTIType: CompatibilityType]] = [
        .enfj: [//
            .enfj: .good,
            .entj: .good,
            .enfp: .good,
            .entp: .good,
            .esfp: .bad,
            .esfj: .bad,
            .estp: .bad,
            .estj: .bad,
            .infp: .best,
            .infj: .good,
            .intp: .good,
            .istp: .bad,
            .isfp: .best,
            .isfj: .bad,
            .istj: .bad,
            .intj: .good
        ],
        .entj: [//
            .enfj: .good,
            .entj: .good,
            .enfp: .good,
            .entp: .good,
            .esfp: .nomal,
            .esfj: .nomal,
            .estp: .nomal,
            .estj: .nomal,
            .infp: .best,
            .infj: .good,
            .intp: .best,
            .istp: .nomal,
            .isfp: .nomal,
            .isfj: .nomal,
            .istj: .nomal,
            .intj: .good
        ],
        .enfp: [//
            .enfj: .good,
            .entj: .good,
            .enfp: .good,
            .entp: .good,
            .esfp: .bad,
            .esfj: .bad,
            .estp: .bad,
            .estj: .bad,
            .infp: .good,
            .infj: .best,
            .intp: .good,
            .istp: .bad,
            .isfp: .bad,
            .isfj: .bad,
            .istj: .bad,
            .intj: .best
        ],
        .entp: [//
            .enfj: .good,
            .entj: .good,
            .enfp: .good,
            .entp: .good,
            .esfp: .nomal,
            .esfj: .soso,
            .estp: .nomal,
            .estj: .soso,
            .infp: .good,
            .infj: .best,
            .intp: .good,
            .istp: .nomal,
            .isfp: .nomal,
            .isfj: .soso,
            .istj: .soso,
            .intj: .best
        ],
        .esfp: [//
            .enfj: .bad,
            .entj: .nomal,
            .enfp: .bad,
            .entp: .nomal,
            .esfp: .soso,
            .esfj: .nomal,
            .estp: .soso,
            .estj: .nomal,
            .infp: .bad,
            .infj: .bad,
            .intp: .nomal,
            .istp: .soso,
            .isfp: .soso,
            .isfj: .best,
            .istj: .best,
            .intj: .nomal
        ],
        .esfj: [//
            .enfj: .bad,
            .entj: .nomal,
            .enfp: .bad,
            .entp: .soso,
            .esfp: .nomal,
            .esfj: .good,
            .estp: .nomal,
            .estj: .good,
            .infp: .bad,
            .infj: .bad,
            .intp: .soso,
            .istp: .best,
            .isfp: .best,
            .isfj: .good,
            .istj: .good,
            .intj: .soso
        ],
        .estp: [//
            .enfj: .bad,
            .entj: .nomal,
            .enfp: .bad,
            .entp: .nomal,
            .esfp: .soso,
            .esfj: .nomal,
            .estp: .soso,
            .estj: .nomal,
            .infp: .bad,
            .infj: .bad,
            .intp: .nomal,
            .istp: .soso,
            .isfp: .soso,
            .isfj: .best,
            .istj: .best,
            .intj: .nomal
        ],
        .estj: [//
            .enfj: .bad,
            .entj: .nomal,
            .enfp: .bad,
            .entp: .soso,
            .esfp: .nomal,
            .esfj: .good,
            .estp: .nomal,
            .estj: .good,
            .infp: .bad,
            .infj: .bad,
            .intp: .best,
            .istp: .best,
            .isfp: .best,
            .isfj: .good,
            .istj: .good,
            .intj: .soso
        ],
        .infp: [//
            .enfj: .best,
            .entj: .best,
            .enfp: .good,
            .entp: .good,
            .esfp: .bad,
            .esfj: .bad,
            .estp: .bad,
            .estj: .bad,
            .infp: .good,
            .infj: .good,
            .intp: .good,
            .istp: .bad,
            .isfp: .bad,
            .isfj: .bad,
            .istj: .bad,
            .intj: .good
        ],
        .infj: [//
            .enfj: .good,
            .entj: .good,
            .enfp: .best,
            .entp: .best,
            .esfp: .bad,
            .esfj: .bad,
            .estp: .bad,
            .estj: .bad,
            .infp: .good,
            .infj: .good,
            .intp: .good,
            .istp: .bad,
            .isfp: .bad,
            .isfj: .bad,
            .istj: .bad,
            .intj: .good
        ],
        .intp: [//
            .enfj: .good,
            .entj: .best,
            .enfp: .good,
            .entp: .good,
            .esfp: .nomal,
            .esfj: .soso,
            .estp: .nomal,
            .estj: .best,
            .infp: .good,
            .infj: .good,
            .intp: .good,
            .istp: .nomal,
            .isfp: .nomal,
            .isfj: .soso,
            .istj: .soso,
            .intj: .good
        ],
        .istp: [//
            .enfj: .bad,
            .entj: .nomal,
            .enfp: .bad,
            .entp: .nomal,
            .esfp: .soso,
            .esfj: .best,
            .estp: .soso,
            .estj: .best,
            .infp: .bad,
            .infj: .bad,
            .intp: .nomal,
            .istp: .soso,
            .isfp: .soso,
            .isfj: .nomal,
            .istj: .nomal,
            .intj: .nomal
        ],
        .isfp: [//
            .enfj: .best,
            .entj: .nomal,
            .enfp: .bad,
            .entp: .nomal,
            .esfp: .soso,
            .esfj: .best,
            .estp: .soso,
            .estj: .best,
            .infp: .bad,
            .infj: .bad,
            .intp: .nomal,
            .istp: .soso,
            .isfp: .soso,
            .isfj: .nomal,
            .istj: .nomal,
            .intj: .nomal
        ],
        .isfj: [//
            .enfj: .bad,
            .entj: .nomal,
            .enfp: .bad,
            .entp: .soso,
            .esfp: .best,
            .esfj: .good,
            .estp: .best,
            .estj: .good,
            .infp: .bad,
            .infj: .bad,
            .intp: .soso,
            .istp: .nomal,
            .isfp: .nomal,
            .isfj: .good,
            .istj: .good,
            .intj: .soso
        ],
        .istj: [
            .enfj: .bad,
            .entj: .nomal,
            .enfp: .bad,
            .entp: .soso,
            .esfp: .best,
            .esfj: .good,
            .estp: .best,
            .estj: .good,
            .infp: .bad,
            .infj: .bad,
            .intp: .soso,
            .istp: .nomal,
            .isfp: .nomal,
            .isfj: .good,
            .istj: .good,
            .intj: .soso
        ],
        .intj: [
            .enfj: .good,
            .entj: .good,
            .enfp: .best,
            .entp: .best,
            .esfp: .nomal,
            .esfj: .soso,
            .estp: .nomal,
            .estj: .soso,
            .infp: .good,
            .infj: .good,
            .intp: .good,
            .istp: .nomal,
            .isfp: .nomal,
            .isfj: .soso,
            .istj: .soso,
            .intj: .good
        ]
    ]
}
