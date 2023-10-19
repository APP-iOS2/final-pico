//
//  SettingSecessionViewController.swift
//  Pico
//
//  Created by 김민기 on 2023/10/19.
//

import UIKit
import SnapKit

final class SettingSecessionViewController: UIViewController {

    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("회원 탈퇴", for: .normal)
        button.setTitleColor(.picoFontBlack, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewConfig()
        addSubView()
        makeConstraints()
    }
    
    private func viewConfig() {
        title = "회원관리"
        view.backgroundColor = .systemBackground
        button.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
    }
    
    private func addSubView() {
        view.addSubview([button])
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        button.snp.makeConstraints { make in
            make.top.equalTo(safeArea.snp.top).offset(100)
            make.leading.equalToSuperview().offset(15)
        }
    }
    
    @objc private func tappedButton() {
        print("삭제")
    }
}
