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
    private var cooldownTimer: Timer?
    private var cooldownSeconds = 180
    private let phoneNumberSubject = BehaviorSubject<String>(value: "")
    private var isFullPhoneNumber: Bool = false
    private var isTappedAuthButton: Bool = false
    private var authTextFields: [UITextField] = []
    private var authText: String = ""
    private var isAdmin: Bool = false
    
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
        tappedDismissKeyboard(without: [nextButton])
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
        cooldownTimer?.invalidate()
        cooldownTimer = nil
        cooldownSeconds = 180
        authButton.setTitle("  인증  ", for: .normal)
        authButton.tintColor = .white
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
                guard isFullPhoneNumber else { return }
                guard let text = phoneNumberTextField.text else { return }
                
                guard !isAdmin else {
                    goAdmin()
                    return
                }
                guard cooldownTimer == nil else {
                    return
                }
                
                viewModel.signIn(userNumber: text) { [weak self] user, message in
                    guard let self = self else { return }
                    
                    guard self.viewModel.isRightUser else {
                        self.checkService.checkBlockUser(userNumber: text) { [weak self] isBlock in
                            guard let self = self else { return }
                            
                            if isBlock {
                                Loading.hideLoading()
                                showCustomAlert(alertType: .onlyConfirm, titleText: "알림", messageText: "탈퇴한 유저입니다.", confirmButtonText: "확인", comfrimAction: configReset)
                            } else {
                                Loading.hideLoading()
                                showCustomAlert(alertType: .onlyConfirm, titleText: "알림", messageText: message, confirmButtonText: "확인", comfrimAction: configReset)
                            }
                        }
                        return
                    }
                    Loading.hideLoading()
                    if let user = user {
                        UserDefaultsManager.shared.setUserData(userData: user)
                    }
                    showCustomAlert(alertType: .onlyConfirm, titleText: "알림", messageText: "인증번호를 전송했습니다.", confirmButtonText: "확인", comfrimAction: { [weak self] in
                            guard let self = self else { return }
                            
                            cooldownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCooldown), userInfo: nil, repeats: true)
                            RunLoop.main.add(cooldownTimer!, forMode: .common)
                            
                            NotificationService.shared.saveToken()
                            configTappedAuthButtonState()
                            authManager.sendVerificationCode(number: text)
                    })
                }
                
            })
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                cancelButton.tappedAnimation()
                phoneNumberTextField.text = ""
                updateAuthButton(isEnable: false, isHidden: true)
                phoneNumberTextField.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                configAuthText()
                if authManager.checkRightCode(code: authText) {
                    showCustomAlert(alertType: .onlyConfirm, titleText: "알림", messageText: "인증에 성공하셨습니다.", confirmButtonText: "확인", comfrimAction: { [weak self] in
                        guard let self = self else { return }
                        
                        let viewController = LoginSuccessViewController()
                        self.navigationController?.pushViewController(viewController, animated: true)
                    })
                } else {
                    showCustomAlert(alertType: .onlyConfirm, titleText: "경고", messageText: "인증번호가 틀렸습니다.", confirmButtonText: "확인")
                    return
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
    @objc private func updateCooldown() {
        cooldownSeconds -= 1
        
        if cooldownSeconds <= 0 {
            cooldownTimer?.invalidate()
            cooldownTimer = nil
            cooldownSeconds = 180
            updateAuthButton(isEnable: true, isHidden: false)
            authButton.setTitle("  재전송  ", for: .normal)
        } else {
            authButton.setTitleColor(.picoBlue, for: .normal)
            authButton.setTitle("\(cooldownSeconds)초", for: .normal)
        }
    }
    private func goAdmin() {
        let viewController = AdminViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
extension SignInViewController: UIGestureRecognizerDelegate {
    func tappedDismissKeyboard(without buttons: [UIButton]) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton {
            return false
        }
        return true
    }
}
// MARK: - 텍스트필드 관련
extension SignInViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard isTappedAuthButton else {
            let text = textField.text
            if text?.replacingOccurrences(of: "-", with: "") == "486" {
                isAdmin = true
                updateAuthButton(isEnable: true, isHidden: false)
                return false
            }
            
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
