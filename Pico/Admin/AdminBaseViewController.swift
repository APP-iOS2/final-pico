//
//  AdminBaseViewController.swift
//  Pico
//
//  Created by 최하늘 on 10/12/23.
//

import UIKit

class AdminBaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configNavigationLogo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true
        configNavigationBackButton()
    }
    
    private func configUI() {
        view.configBackgroundColor()
        view.tappedDismissKeyboard()
        configNavigationBgColor()
    }
}
