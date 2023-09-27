//
//  NavigationLogo.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/26.
//

import UIKit
import SnapKit

extension UIViewController {
    /// logo leftBarButton
    /// -> viewDidLoad에서 호출
    func configLogoBarItem() {
        let logoButton = UIButton(type: .system)
        let image = UIImage(named: "logo")
        logoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        let leftItem = UIBarButtonItem(customView: logoButton)
        leftItem.customView?.snp.makeConstraints({ make in
            make.height.equalTo(28)
            make.width.equalTo(getRatio(image, height: 28))
        })
        navigationItem.leftBarButtonItem = leftItem
    }
    
    private func getRatio(_ image: UIImage?, height: CGFloat = 0, width: CGFloat = 0) -> CGFloat {
        guard let image = image else { return  0 }
        let widthRatio = CGFloat(image.size.width / image.size.height)
        let heightRatio = CGFloat(image.size.height / image.size.width)
        
        if height != 0 {
            return height / heightRatio
        }
        if width != 0 {
            return width / widthRatio
        }
        return 0
    }
}
