//
//  SignViewController.swift
//  Pico
//
//  Created by LJh on 2023/09/25.
//

import UIKit
import SwiftUI
import SnapKit

final class SignViewController: UIViewController {
    
    private let picoLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let picoChuImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "chu")
        return imageView
        
    }()
    
    private let signInButton: CommonButton = {
        let button = CommonButton(type: .custom)
        button.setTitle("로그인", for: .normal)
        return button
    }()
    
    private let signUpButton: CommonButton = {
        let button = CommonButton(type: .custom)
        button.setTitle("회원가입", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addSubViews()
        makeConstraints()
        configButton()
    }
    
    @objc private func tappedSignInButton(_ sender: UIButton) {
        tappedButtonAnimation(sender)
        let viewController = SignInViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func tappedSignUpButton(_ sender: UIButton) {
        tappedButtonAnimation(sender)
        let viewController = SignUpViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func configButton() {
        signInButton.addTarget(self, action: #selector(tappedSignInButton), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(tappedSignUpButton), for: .touchUpInside)
    }
    
    private func addSubViews() {
        for viewItem in [picoLogoImageView, picoChuImageView, signInButton, signUpButton] {
            view.addSubview(viewItem)
        }
    }
    
    private func makeConstraints() {
        let safeArea = self.view.safeAreaLayoutGuide
        
        picoLogoImageView.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(30)
            make.leading.equalTo(50)
            make.trailing.equalTo(-50)
            make.height.equalTo(100)
        }
        
        picoChuImageView.snp.makeConstraints { make in
            make.top.equalTo(picoLogoImageView.snp.bottom).offset(50)
            make.leading.equalTo(50)
            make.trailing.equalTo(-50)
            make.height.equalTo(200)
        }
        
        signInButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.bottom.equalTo(signUpButton.snp.top).offset(-20)
            make.height.equalTo(signUpButton.snp.height)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.bottom.equalTo(safeArea).offset(-100)
            make.height.equalTo(50)
        }
    }
    
}
