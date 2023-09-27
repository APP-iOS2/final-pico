//
//  LoginSuccessViewController.swift
//  Pico
//
//  Created by LJh on 2023/09/25.
//

import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addSubViews()
        makeConstraints()
        configButton()
    }

    // MARK: - cofig
    private func configButton() {
        nextButton.addTarget(self, action: #selector(tappedNextButton), for: .touchUpInside)
    }

    @objc private func tappedNextButton(_ sender: UIButton) {
        tappedButtonAnimation(sender)
//        if isTappedNextButton {
//            let viewController = LoginSuccessViewController()
//            self.navigationController?.pushViewController(viewController, animated: true)
//        }
    }
    
    // MARK: - UI 관련
    private func addSubViews() {
        for viewItem in [notifyLabel, checkImageView, nextButton] {
            view.addSubview(viewItem)
        }
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        notifyLabel.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        checkImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(150)
            make.trailing.equalToSuperview().offset(-150)
            make.centerY.equalTo(safeArea)
        }
        
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.bottom.equalTo(safeArea).offset(-30)
            make.height.equalTo(50)
        }
    }
}
