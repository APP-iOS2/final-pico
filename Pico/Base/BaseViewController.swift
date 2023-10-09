//
//  BaseViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/26.
//

import UIKit
import SnapKit
/*
 사용법: 상속해서 사용하시면 됩니다
 class MainViewController: BaseViewController {
*/

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configNavigationLogo()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true
    }
    
    private func configUI() {
        view.configBackgroundColor()
        view.tappedDismissKeyboard()
        configNavigationBgColor()
        configNavigationBackButton()
    }
}
