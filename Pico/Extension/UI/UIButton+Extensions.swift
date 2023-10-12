//
//  UIButton+Extensions.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/26.
//

import UIKit

extension UIButton {
    /// 버튼 눌렸을 때 애니메이션
    func tappedAnimation() {
        UIView.animate(withDuration: 0.25, animations: {
            self.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }, completion: { _ in
            UIView.animate(withDuration: 0.255, animations: {
                self.transform = CGAffineTransform.identity
            })
        })
    }
}
