//
//  CircleImageView.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/26.
//

import UIKit

extension UIViewController {
    /// 원형 이미지 만들기
    /// -> viewDidLayoutSubviews에서 호출
    func setCircleImageView(imageView: UIImageView, border: CGFloat = 0, borderColor: CGColor = UIColor.clear.cgColor) {
        imageView.layer.cornerRadius = imageView.frame.width / 2.0
        imageView.layer.borderWidth = border
        imageView.layer.borderColor = borderColor
        imageView.clipsToBounds = true
    }
}
