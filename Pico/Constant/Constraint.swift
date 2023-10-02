//
//  Constraint.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import Foundation

struct Constraint {
    struct Button {
        /// 버튼 높이 (50)
        static let commonHeight: CGFloat = 50
    }
    
    struct SignView {
        /// 제목 padding (15)
        static let padding: CGFloat = 15
        
        /// 서브제목 top padding (5)
        static let subPadding: CGFloat = 5
        
        /// 내용 padding (20)
        static let contentPadding: CGFloat = 20
        
        /// 버튼 bottomPadding (-30)
        static let bottomPadding: CGFloat = -30
        
        /// 프로그레스 뷰 cornerRadius (0)
        static let progressViewTopPadding: CGFloat = 0
        
        /// 프로그레스 뷰 cornerRadius (4)
        static let progressViewCornerRadius: CGFloat = 4
    }
    
    struct MypageView {
        /// 마이페이지의 프로필 뷰 높이
        static var profileViewHeight: CGFloat = 240
        /// 마이페이지의 프로필 최대 높이 (240)
        static let profileViewMaxHeight: CGFloat = 240
    }
}
