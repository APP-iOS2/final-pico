//
//  DismissKeyboard.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit

extension UIViewController {
    /// 배경 탭하면 키보드 내리기
    func tappedDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
