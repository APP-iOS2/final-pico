//
//  UIViewController+Extensions.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit

extension UIViewController {
    /// 배경 탭하면 키보드 내리기
    func picoVcTappedDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /// 알림창 띄우기
    func picoVcShowAlert(message: String, title: String = "알림", isCancelButton: Bool = false, yesAction: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let yes = UIAlertAction(title: "확인", style: .default) {_ in
            yesAction?()
        }
        if isCancelButton {
            let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            alert.addAction(cancel)
        }
        alert.addAction(yes)
        
        present(alert, animated: true, completion: nil)
    }
    
    /// 네비게이션 뒤로가기 버튼 타이틀 변경
    /// -> 사용방법: a에서 b로 이동한다면 a에서 선언
    func picoVcChangeNavigationBackButton() {
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    /// 원형 이미지 만들기
    /// -> viewDidLayoutSubviews에서 호출
    func picoVcSetCircleImageView(imageView: UIImageView, border: CGFloat = 0, borderColor: CGColor = UIColor.clear.cgColor) {
        imageView.layer.cornerRadius = imageView.frame.width / 2.0
        imageView.layer.borderWidth = border
        imageView.layer.borderColor = borderColor
        imageView.clipsToBounds = true
    }
    
    /// logo leftBarButton
    /// -> viewDidLoad에서 호출
    func configLogoBarItem() {
        var logoImage = UIImage(named: "logo")
        logoImage = logoImage?.withRenderingMode(.alwaysOriginal)
        
        let logoButton = UIBarButtonItem(image: logoImage, style: .plain, target: nil, action: nil)
        logoButton.isEnabled = false
        navigationItem.leftBarButtonItem = logoButton
    }
    
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
