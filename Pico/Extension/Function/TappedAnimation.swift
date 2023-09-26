//
//  TappedAnimation.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/26.
//

import UIKit

extension UIViewController {
    /// 버튼 눌렸을 때 애니메이션
    func tappedButtonAnimation(_ sender: UIButton) {
        UIView.animate(withDuration: 0.25, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { _ in
            UIView.animate(withDuration: 0.255, animations: {
                sender.transform = CGAffineTransform.identity
            })
        })
    }
}
