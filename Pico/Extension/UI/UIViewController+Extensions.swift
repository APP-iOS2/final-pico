//
//  UIViewController+Extensions.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/26.
//

import UIKit
import SnapKit

extension UIViewController {
    /// logo leftBarButton
    /// -> navigationItem.configNavigationLogo() 호출
    func configNavigationLogo() {
        let logoButton = UIButton(type: .system)
        let image = UIImage(named: "logo")
        logoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        
        let leftItem = UIBarButtonItem(customView: logoButton)
        let height: CGFloat = 26
        leftItem.customView?.snp.makeConstraints({ make in
            make.height.equalTo(height)
            make.width.equalTo(image?.getRatio(height: height) ?? 0)
        })
        leftItem.isEnabled = false
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    /// 네비게이션 뒤로가기 버튼
    /// -> 사용방법: a에서 b로 이동한다면 a에서 선언
    func configNavigationBackButton() {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let backImage = UIImage(systemName: "chevron.left", withConfiguration: imageConfig)
        navigationController?.navigationBar.backIndicatorImage = backImage
        backImage?.accessibilityLabel = "뒤로가기"
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.tintColor = .picoBlue
    }
    
    /// 네비게이션 뒤로가기 버튼 숨기기
    /// -> 사용방법: a에서 b로 이동한다면 a에서 선언
    func hideNavigationBackButton() {
        self.navigationItem.hidesBackButton = true
    }
    
    /// 네비게이션 safeArea 까지의 배경색 설정
    func configNavigationBgColor(backgroundColor: UIColor = .systemBackground) {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = backgroundColor
        navigationBarAppearance.shadowColor = .clear // 밑줄 제거
        navigationBarAppearance.shadowImage = UIImage() // 밑줄 제거
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    }
    
    /// 알림창 띄우기
    func showAlert(message: String, title: String = "알림", isCancelButton: Bool = false, yesAction: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let yes = UIAlertAction(title: "확인", style: .default) { _ in
            yesAction?()
        }
        
        if isCancelButton {
            let cancel = UIAlertAction(title: "취소", style: .destructive, handler: nil)
            alert.addAction(cancel)
        }
        alert.addAction(yes)
        
        present(alert, animated: true, completion: nil)
    }
    
    /// 커스텀 알럿 띄우기
    func showCustomAlert(
        alertType: AlertType,
        titleText: String,
        messageText: String,
        cancelButtonText: String? = "취소",
        confirmButtonText: String,
        comfrimAction: (() -> Void)? = nil,
        cancelAction: (() -> Void)? = nil
    ) {
        let customAlertViewController = CustomPopupViewController()
        
        customAlertViewController.modalPresentationStyle = .overFullScreen
        customAlertViewController.modalTransitionStyle = .crossDissolve
        customAlertViewController.alertType = alertType
        customAlertViewController.titleText = titleText
        customAlertViewController.messageText = messageText
        customAlertViewController.cancelButtonText = cancelButtonText ?? "취소"
        customAlertViewController.confirmButtonText = confirmButtonText
        customAlertViewController.confirmAction = comfrimAction
        customAlertViewController.cancelAction = cancelAction
        self.present(customAlertViewController, animated: true, completion: nil)
    }
}
