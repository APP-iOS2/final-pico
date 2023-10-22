//
//  SettingLicenseViewController.swift
//  Pico
//
//  Created by 김민기 on 2023/10/19.
//

import SwiftUI
import SnapKit

final class SettingLicenseViewController: UIViewController {
    
    private let settingLicenseView = SettingLicenseView()
    private lazy var hostingController = UIHostingController(rootView: settingLicenseView)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewConfig()
        addSubView()
        makeConstraints()
    }
    
    private func viewConfig() {
        title = "오픈소스 라이센스"
        view.configBackgroundColor()
    }
    
    private func addSubView() {
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
    
    private func makeConstraints() {
        hostingController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
