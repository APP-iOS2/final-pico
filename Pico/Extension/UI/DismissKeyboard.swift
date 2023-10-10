//
//  UIView+Extensions.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit

extension UIView {
    /// 기본 배경색 설정
    func configBgColor() {
        self.backgroundColor = .systemBackground
    }
    
    /// 배경 탭하면 키보드 내리기
    func tappedDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        self.endEditing(true)
    }
    
    /// 원형 이미지 만들기
    /// -> viewDidLayoutSubviews에서 호출
    func setCircleImageView(imageView: UIImageView, border: CGFloat = 0, borderColor: CGColor = UIColor.clear.cgColor) {
        imageView.layer.cornerRadius = imageView.frame.width / 2.0
        imageView.layer.borderWidth = border
        imageView.layer.borderColor = borderColor
        imageView.clipsToBounds = true
    }
}
