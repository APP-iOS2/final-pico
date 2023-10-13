//
//  ProfileEditTextModalViewController.swift
//  Pico
//
//  Created by 김민기 on 2023/10/13.
//

import UIKit
import SnapKit
import RxSwift
/*직장 내소개 키 뷰*/
final class ProfileEditTextModalViewController: UIViewController {
    
    private let backButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        let image = UIImage(systemName: "xmark", withConfiguration: imageConfig)
        let button = UIButton()
        button.layer.masksToBounds = false
        button.layer.cornerRadius = 15
        button.backgroundColor = .picoGray
        button.setImage(image, for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .picoTitleFont
        label.textColor = .picoFontBlack
        label.text = "종교"
        return label
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = .picoTitleFont
        textField.textColor = .gray
        return textField
    }()
    
    private lazy var cancleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "x.circle"), for: .normal)
        button.tintColor = .black
        button.imageView?.contentMode = .scaleAspectFit
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let completeButton: UIButton = {
        let button = UIButton()
        button.setTitle("완료", for: .normal)
        button.layer.masksToBounds = false
        button.layer.cornerRadius = 15
        button.backgroundColor = .picoBlue
        return button
    }()
    
    private let profileEditModalViewModel = ProfileEditModalViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addViews()
        makeConstraints()
        binds()
    }
    
    private func binds() {
        backButton.rx.tap
            .bind {
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        completeButton.rx.tap
            .bind {
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        profileEditModalViewModel.name
            .bind(to: textField.rx.placeholder)
            .disposed(by: disposeBag)
        
        profileEditModalViewModel.name
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)

    }
    
    private func addViews() {
        view.addSubview([backButton, titleLabel, textField, cancleButton, completeButton])
    }
    
    private func makeConstraints() {
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-15)
            make.width.height.equalTo(30)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
        }
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalTo(cancleButton.snp.leading).offset(-10)
            make.height.equalTo(30)
        }
        cancleButton.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.top)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(30)
        }
        
        completeButton.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(30)
//            make.bottom.equalToSuperview().offset(-50)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(40)
        }
    }
    
}
