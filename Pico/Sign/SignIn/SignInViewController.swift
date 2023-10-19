//
//  SignInViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SignInViewController: UIViewController {
    private let authManager = SMSAuthManager()
    private let keyboardManager = KeyboardManager()
    private let checkService = CheckService()
    private let viewModel = SignInViewModel()
    private let disposeBag = DisposeBag()
    private let phoneNumberSubject = BehaviorSubject<String>(value: "")
    private var isFullPhoneNumber: Bool = false
    private var isTappedAuthButton: Bool = false
    private var authTextFields: [UITextField] = []
    private var authText: String = ""
    
    private let notifyLabel: UILabel = {
        let label = UILabel()
        label.text = "가입하신 전화번호를 입력하세요."
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.picoTitleFont
        return label
    }()
    
    private let phoneNumberTextField: UITextField = {
        let textField = UITextField()
        textField.font = .picoTitleFont
        textField.placeholder = "번호를 입력하세요."
        textField.textColor = .gray
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        let image = UIImage(systemName: "x.circle", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .picoGray
        return button
    }()
    
    private let authButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("  인증  ", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 13
        button.backgroundColor = .picoBlue
        button.isHidden = true
        return button
    }()
    
    private let buttonHorizontalStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    private let authTextFieldStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.isHidden = true
        return stackView
    }()
    
    private let nextButton: UIButton = {
        let button = CommonButton(type: .custom)
        button.setTitle("다음", for: .normal)
        button.backgroundColor = .picoGray
        button.isEnabled = false
        return button
    }()
    
    // MARK: - LifeCyle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.configBackgroundColor()
        view.tappedDismissKeyboard()
        addSubViews()
        makeConstraints()
        configTextfield()
        configButton()
        configAuthTextField()
        NotificationService.shared.registerRemoteNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardManager.registerKeyboard(with: nextButton)
        phoneNumberTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardManager.unregisterKeyboard()
    }
}
// MARK: - Config
extension SignInViewController {
    
    private func configTextfield() {
        phoneNumberTextField.delegate = self
    }
    
    private func configReset() {
        keyboardManager.registerKeyboard(with: nextButton)
        isFullPhoneNumber = false
        isTappedAuthButton = false
        for authTextField in authTextFields {
            authTextField.text = ""
        }
        authText = ""
        
        phoneNumberTextField.becomeFirstResponder()
        phoneNumberTextField.text = ""
        updatePhoneNumberTextField(isFull: false)
        updateCancelButton(isHidden: false)
        updateAuthButton(isEnable: false, isHidden: true)
        updateAuthTextFieldStack(isShow: false)
        updateNextButton(isEnabled: false)
    }
    
    private func configAuthText() {
        var authStrings: [String] = []
        for text in authTextFields {
            authStrings.append(text.text ?? "")
        }
        authText = authStrings.joined()
    }
    
    private func configTappedAuthButtonState() {
        self.authTextFields[0].becomeFirstResponder()
        self.isTappedAuthButton = true
        self.updatePhoneNumberTextField(isFull: true)
        self.updateCancelButton(isHidden: true)
        self.updateAuthButton(isEnable: false, isHidden: false)
        self.updateAuthTextFieldStack(isShow: true)
        self.updateNextButton(isEnabled: true)
    }
    
    private func configButton() {
        authButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                authButton.tappedAnimation()
                guard self.isFullPhoneNumber else { return }
                guard let text = self.phoneNumberTextField.text else { return }
                
                showAlert(message: "\(text) 번호로 인증번호를 전송합니다.", isCancelButton: true) {
                    self.viewModel.signIn(userNumber: text) { user, string in
                        guard self.viewModel.isRightUser else {
                            self.checkService.checkBlockUser(userNumber: text) { isBlock in
                                if isBlock {
                                    Loading.hideLoading()
                                    self.showAlert(message: "차단된 유저입니다.") {
                                        self.configReset()
                                    }
                                } else {
                                    Loading.hideLoading()
                                    self.showAlert(message: string) {
                                        self.configReset()
                                    }
                                }
                            }
                            return
                        }
                        
                        if let user = user {
                            UserDefaultsManager.shared.setUserData(userData: user)
                        }
                        NotificationService.shared.saveToken()
                        Loading.hideLoading()
                        self.configTappedAuthButtonState()
                        self.authManager.sendVerificationCode()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                cancelButton.tappedAnimation()
                self.phoneNumberTextField.text = ""
                updateAuthButton(isEnable: false, isHidden: true)
                phoneNumberTextField.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.configAuthText()
                guard let self = self else { return }
                guard authManager.checkRightCode(code: authText) else {
                    showAlert(message: "비상비상 인증실패") { self.configReset() }
                    return
                }
                showAlert(message: "인증에 성공하셨습니다.") {
                    let viewController = LoginSuccessViewController()
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
    // MARK: - Update
    private func updatePhoneNumberTextField(isFull: Bool) {
        phoneNumberTextField.isEnabled = !isFull
        phoneNumberTextField.textColor = isFull ? .picoBlue : .gray
    }

    private func updateCancelButton(isHidden: Bool) {
        cancelButton.isHidden = isHidden
    }
    
    private func updateAuthButton(isEnable: Bool, isHidden: Bool = false) {
        authButton.isEnabled = isEnable
        authButton.backgroundColor = isEnable ? .picoBlue : .picoGray
        authButton.isHidden = isHidden
        isFullPhoneNumber = isEnable
    }
    
    private func updateAuthTextFieldStack(isShow: Bool) {
        authTextFieldStack.isHidden = isShow ? false : true
    }
    
    private func updateNextButton(isEnabled: Bool) {
        nextButton.backgroundColor = isEnabled ? .picoBlue : .picoGray
        nextButton.isEnabled = isEnabled
    }
  
}
// MARK: - 텍스트필드 관련
extension SignInViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard isTappedAuthButton else {
            let isChangeValue = changePhoneNumDigits(textField, shouldChangeCharactersIn: range, replacementString: string) { isEnable in
                let isHidden = !isEnable
                updateAuthButton(isEnable: isEnable, isHidden: isHidden)
            }
            return isChangeValue
        }
        
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) && updatedText.count <= 1 else { return false }
        
        if let currentIndex = authTextFields.firstIndex(of: textField), currentIndex < authTextFields.count - 1 {
            if updatedText.isEmpty {
                authTextFields[currentIndex].text = updatedText
            } else {
                authTextFields[currentIndex].text = updatedText
                if currentIndex < authTextFields.count - 1 {
                    authTextFields[currentIndex + 1].becomeFirstResponder()
                }
            }
        }
        return false
    }
}
// MARK: - UI 관련
extension SignInViewController {
    
    private func addSubViews() {
        configAuthTextField()
        for stackViewItem in [phoneNumberTextField, cancelButton, authButton] {
            buttonHorizontalStack.addArrangedSubview(stackViewItem)
        }
        for pmStkItem in authTextFields {
            authTextFieldStack.addArrangedSubview(pmStkItem)
        }
        for viewItem in [notifyLabel, buttonHorizontalStack, nextButton, authTextFieldStack] {
            view.addSubview(viewItem)
        }
    }
    
    private func configAuthTextField() {
        for tag in 0...5 {
            let textField = UITextField()
            textField.layer.borderWidth = 1
            textField.layer.cornerRadius = 10
            textField.textAlignment = .center
            textField.font = .picoTitleFont
            textField.textColor = .picoBlue
            textField.keyboardType = .numberPad
            textField.delegate = self
            textField.layer.borderColor = UIColor.picoGray.cgColor
            textField.tag = tag
            textField.clipsToBounds = true
            authTextFields.append(textField)
        }
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        notifyLabel.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(10)
            make.leading.equalToSuperview().offset(SignView.padding)
            make.trailing.equalToSuperview().offset(-SignView.padding)
        }
        
        buttonHorizontalStack.snp.makeConstraints { make in
            make.top.equalTo(notifyLabel.snp.bottom).offset(SignView.contentPadding)
            make.leading.equalToSuperview().offset(SignView.contentPadding)
            make.trailing.equalToSuperview().offset(-SignView.contentPadding)
            make.height.equalTo(30)
        }
        
        authButton.snp.makeConstraints { make in
            make.width.equalTo(60)
        }
        authTextFieldStack.snp.makeConstraints { make in
            make.top.equalTo(buttonHorizontalStack.snp.bottom).offset(SignView.contentPadding)
            make.leading.equalTo(SignView.contentPadding)
            make.trailing.equalTo(-SignView.contentPadding)
            make.height.equalTo(50)
        }
        nextButton.snp.makeConstraints { make in
            make.leading.equalTo(notifyLabel.snp.leading)
            make.trailing.equalTo(notifyLabel.snp.trailing)
            make.bottom.equalTo(safeArea).offset(SignView.bottomPadding)
            make.height.equalTo(CommonConstraints.buttonHeight)
        }
        
    }
}
