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
    func configBackButton() {
        // 원하는 크기로 아이콘을 생성합니다.
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let backImage = UIImage(systemName: "chevron.left", withConfiguration: imageConfig)
        self.navigationController?.navigationBar.backIndicatorImage = backImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.tintColor = .picoBlue
    }
}
