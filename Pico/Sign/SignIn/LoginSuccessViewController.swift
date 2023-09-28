//
//  LoginSuccessViewController.swift
//  Pico
//
//  Created by LJh on 2023/09/25.
//

import UIKit
import SnapKit

final class LoginSuccessViewController: UIViewController {

    private let notifyLabel: UILabel = {
        let label = UILabel()
        label.text = "로그인완료"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.picoTitleFont
        return label
    }()
    
    private let checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "checkmark.circle")
        return imageView
    }()
    
    private let nextButton: UIButton = {
        let button = CommonButton(type: .custom)
        button.setTitle("완료", for: .normal)
        return button
    }()
    
    // MARK: - LifeCyle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        hideBackButton()
        addSubViews()
        makeConstraints()
        configButton()
    }

    // MARK: - Config
    private func configButton() {
        nextButton.addTarget(self, action: #selector(tappedNextButton), for: .touchUpInside)
    }
    
    // MARK: - Tapped
    @objc private func tappedNextButton(_ sender: UIButton) {
        tappedButtonAnimation(sender)
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootView(TabBarController(), animated: true)
    }
}

// MARK: - UI 관련
extension LoginSuccessViewController {

    private func addSubViews() {
        for viewItem in [notifyLabel, checkImageView, nextButton] {
            view.addSubview(viewItem)
        }
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        notifyLabel.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(Constraint.SignView.padding)
            make.leading.equalTo(Constraint.SignView.padding)
            make.trailing.equalTo(-Constraint.SignView.padding)
        }
        
        checkImageView.snp.makeConstraints { make in
            make.centerX.equalTo(safeArea)
            make.centerY.equalTo(safeArea)
            make.width.height.equalTo(80)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.equalTo(notifyLabel.snp.leading)
            make.trailing.equalTo(notifyLabel.snp.trailing)
            make.bottom.equalTo(safeArea).offset(Constraint.SignView.bottomPadding)
            make.height.equalTo(Constraint.Button.commonHeight)
        }
    }
}
