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
        configLogoBarItem()
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationItem.leftBarButtonItem = nil
    }
    private func configUI() {
        view.backgroundColor = .systemBackground
        configBackButton()
        tappedDismissKeyboard()
    }
}
