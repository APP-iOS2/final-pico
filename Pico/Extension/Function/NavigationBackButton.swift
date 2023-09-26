//
//  NavigationBackButton.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/26.
//

import UIKit

extension UIViewController {
    /// 네비게이션 뒤로가기 버튼 타이틀 없애기
    /// -> 사용방법: a에서 b로 이동한다면 a에서 선언
    func changeNavigationBackButton() {
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = backBarButtonItem
    }
}
