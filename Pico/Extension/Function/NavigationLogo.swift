//
//  NavigationLogo.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/26.
//

import UIKit

extension UIViewController {
    /// logo leftBarButton
    /// -> viewDidLoad에서 호출
    func configLogoBarItem() {
        var logoImage = UIImage(named: "logo")
        logoImage = logoImage?.withRenderingMode(.alwaysOriginal)
        
        let logoButton = UIBarButtonItem(image: logoImage, style: .plain, target: nil, action: nil)
        logoButton.isEnabled = false
        navigationItem.leftBarButtonItem = logoButton
    }
}
