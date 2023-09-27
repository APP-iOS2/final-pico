//
//  SignUpNickNameViewController.swift
//  Pico
//
//  Created by LJh on 2023/09/27.
//

import UIKit

class SignUpNickNameViewController: UIViewController {
    
    private let progressView: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = .picoBetaBlue
        view.progressTintColor = .picoBlue
        view.progress = 0.142 * 4
        view.layer.cornerRadius = 5
        return view
    }()
    
    private let notifyLabel: UILabel = {
        let label = UILabel()
        label.text = "생년월일을 선택하세요"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.picoTitleFont
        return label
    }()
    
    private let subNotifyLabel: UILabel = {
        let label = UILabel()
        label.text = "생년월일은 변경이 불가능합니다‼️"
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.textColor = .picoFontGray
        label.font = UIFont.picoDescriptionFont
        return label
    }()
  
    private lazy var nextButton: UIButton = {
        let button = CommonButton(type: .custom)
        button.setTitle("다음", for: .normal)
        button.backgroundColor = .picoGray
        button.addTarget(self, action: #selector(tappedNextButton), for: .touchUpInside)
        return button
    }()
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - config
extension SignUpNickNameViewController {
    @objc private func tappedNextButton(_ sender: UIButton) {
        
    }
}

// MARK: - UI 관련
extension SignUpNickNameViewController {
    private func addSubViews() {
        
    }
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
    }
}

