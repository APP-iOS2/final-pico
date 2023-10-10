//
//  LoginSuccessViewController.swift
//  Pico
//
//  Created by LJh on 2023/09/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class LoginSuccessViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
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
        imageView.tintColor = .picoBlue
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
        view.configBackgroundColor()
        hideNavigationBackButton()
        addSubViews()
        makeConstraints()
        configButton()
    }
}

// MARK: - Config
extension LoginSuccessViewController {
    private func configButton() {
        nextButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                nextButton.tappedAnimation()
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootView(TabBarController(), animated: true)
            })
            .disposed(by: disposeBag)
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
            make.top.equalTo(safeArea).offset(SignView.padding)
            make.leading.equalTo(SignView.padding)
            make.trailing.equalTo(-SignView.padding)
        }
        
        checkImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.equalTo(notifyLabel.snp.leading)
            make.trailing.equalTo(notifyLabel.snp.trailing)
            make.bottom.equalTo(safeArea).offset(SignView.bottomPadding)
            make.height.equalTo(CommonConstraints.buttonHeight)
        }
    }
}
