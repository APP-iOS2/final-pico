//
//  UIStackView+Extensions.swift
//  Pico
//
//  Created by 양성혜 on 2023/10/14.
//

import UIKit

extension UIStackView {
    
    /// [UIView] 배열을 stackView에 추가하기
    func addArrangedSubview(_ views: [UIView]) {
       views.forEach { item in
            self.addArrangedSubview(item)
        }
    }
}
