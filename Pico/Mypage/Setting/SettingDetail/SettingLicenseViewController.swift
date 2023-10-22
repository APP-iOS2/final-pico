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
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        if let symbolImage = UIImage(systemName: "xmark.circle")?.withRenderingMode(.alwaysTemplate) {
            button.setImage(symbolImage, for: .normal)
        }
        button.tintColor = .picoFontGray
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        button.setPreferredSymbolConfiguration(symbolConfiguration, forImageIn: .normal)
        button.addTarget(self, action: #selector(tappedCloseButton), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "오픈소스 라이센스"
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textColor = .picoFontBlack
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewConfig()
        addSubView()
        makeConstraints()
    }
    
    private func viewConfig() {
        view.configBackgroundColor()
    }
    
    private func addSubView() {
        addChild(hostingController)
        view.addSubview([titleLabel, closeButton, hostingController.view])
        hostingController.didMove(toParent: self)
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(30)
            make.centerX.equalTo(safeArea)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel)
            make.trailing.equalTo(safeArea).offset(-15)
        }
        
        hostingController.view.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    @objc private func tappedCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
}
