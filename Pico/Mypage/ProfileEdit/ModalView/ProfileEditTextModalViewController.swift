//
//  ProfileEditTextModalViewController.swift
//  Pico
//
//  Created by 김민기 on 2023/10/13.
//

import UIKit
import SnapKit
import RxSwift
/*직장 내소개  뷰*/
final class ProfileEditTextModalViewController: UIViewController {
    
    private let backButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        let image = UIImage(systemName: "xmark", withConfiguration: imageConfig)
        let button = UIButton()
        button.layer.masksToBounds = false
        button.layer.cornerRadius = 12
        button.backgroundColor = .picoGray
        button.setImage(image, for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .picoSubTitleFont
        label.textColor = .picoFontBlack
        return label
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.font = .picoTitleFont
        textField.textColor = .black
        return textField
    }()
    
    private let cancelButton: UIButton = {
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
        button.backgroundColor = .picoGray
        button.isEnabled = false
        return button
    }()
    
    let profileEditViewModel: ProfileEditViewModel
    private let disposeBag = DisposeBag()
    let checkService = CheckService()
    init(profileEditViewModel: ProfileEditViewModel) {
        self.profileEditViewModel = profileEditViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addViews()
        makeConstraints()
        textFieldConfigure()
        binds()
    }
    
    private func binds() {
        
        profileEditViewModel.modalName
            .bind(to: textField.rx.placeholder)
            .disposed(by: disposeBag)
        
        profileEditViewModel.modalName
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .bind { [weak self] _ in
                guard let self else { return }
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .bind { [weak self] _ in
                guard let self else { return }
                self.self.textField.text = ""
                self.completeButton.isEnabled = false
                self.completeButton.backgroundColor = .picoGray
            }
            .disposed(by: disposeBag)
        
        let text = profileEditViewModel.textData ?? ""
        textField.text = text
        
        completeButton.rx.tap
            .bind { [weak self] _ in
                guard let self else { return }
                self.profileEditViewModel.updateData(data: self.textField.text?.trimmed())
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func textFieldConfigure() {
        textField.delegate = self
    }
    
    private func addViews() {
        view.addSubview([backButton, titleLabel, textField, cancelButton, completeButton])
    }
    
    private func makeConstraints() {
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-15)
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalTo(cancelButton.snp.leading).offset(-10)
            make.height.equalTo(30)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.top)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(30)
        }
        
        completeButton.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(40)
        }
    }
}

extension ProfileEditTextModalViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = profileEditViewModel.textData ?? ""
        let updatedText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        
        if updatedText != text {
            completeButton.isEnabled = true
            completeButton.backgroundColor = .picoBlue
        } else {
            completeButton.isEnabled = false
            completeButton.backgroundColor = .picoGray
        }
        return true
    }
}
