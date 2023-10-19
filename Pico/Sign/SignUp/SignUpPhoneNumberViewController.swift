//
//  SingUpPhoneNumberViewController.swift
//  Pico
//
//  Created by LJh on 2023/09/26.
//

import UIKit
import SnapKit
import RxSwift

final class SignUpPhoneNumberViewController: UIViewController {
    private let keyboardManager = KeyboardManager()
    private let smsAuthManager: SMSAuthManager = SMSAuthManager()
    private let checkService = CheckService()
    let viewModel: SignUpViewModel
    private var cooldownTimer: Timer?
    private var cooldownSeconds = 180
    init(viewModel: SignUpViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var userPhoneNumber: String = ""
    private var isFullPhoneNumber: Bool = false
    private var isTappedCheckButton: Bool = false
    private var authTextFields: [UITextField] = []
    private var authText: String = ""
    
    private let notifyLabel: UILabel = {
        let label = UILabel()
        label.text = "가입하실 전화번호를 입력하세요."
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.picoTitleFont
        return label
    }()
    
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = .lightGray
        view.progressTintColor = .picoBlue
        view.layer.cornerRadius = SignView.progressViewCornerRadius
        view.layer.masksToBounds = true
        view.progress = viewModel.progressStatus
        return view
    }()
    
    private let phoneTextFieldstackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    private let phoneNumberTextField: UITextField = {
        let textField = UITextField()
        textField.font = .picoTitleFont
        textField.textColor = .gray
        textField.keyboardType = .numberPad
        return textField
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
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        let image = UIImage(systemName: "x.circle", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .picoGray
        return button
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
        return button
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.configBackgroundColor()
        tappedDismissKeyboard(without: [nextButton])
        configNavigationBackButton()
        addSubViews()
        makeConstraints()
        configButtons()
        configTextField()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.animateProgressBar(progressView: progressView, endPoint: 2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        keyboardManager.registerKeyboard(with: nextButton)
        phoneNumberTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardManager.unregisterKeyboard()
    }
}
// MARK: - Config
extension SignUpPhoneNumberViewController {
    
    private func configButtons() {
        cancelButton.addTarget(self, action: #selector(tappedCancelButton), for: .touchUpInside)
        authButton.addTarget(self, action: #selector(tappedAuthButton), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(tappedNextButton), for: .touchUpInside)
    }
    
    private func configTextField() {
        phoneNumberTextField.delegate = self
    }
    
    private func configAuthText() {
        var authStrings: [String] = []
        for text in authTextFields {
            authStrings.append(text.text ?? "")
        }
        authText = authStrings.joined()
    }
    
    private func configReset() {
        keyboardManager.registerKeyboard(with: nextButton)
        userPhoneNumber = ""
        isFullPhoneNumber = false
        isTappedCheckButton = false
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
    
    // MARK: - Update 관련 Number, cancel, auth, authField, next
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
    
    private func updateViewState(num: String) {
        self.viewModel.phoneNumber = num
        self.authTextFields[safe: 0]?.becomeFirstResponder()
        self.updatePhoneNumberTextField(isFull: true)
        self.updateCancelButton(isHidden: true)
        self.updateAuthButton(isEnable: false, isHidden: false)
        self.updateAuthTextFieldStack(isShow: true)
        self.updateNextButton(isEnabled: true)
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
            authButton.setTitle("\(cooldownSeconds)초", for: .normal)
        }
    }
    // MARK: - @objc
    @objc private func tappedCancelButton(_ sender: UIButton) {
        sender.tappedAnimation()
        configReset()
    }
    @objc private func tappedAuthButton(_ sender: UIButton) {
        sender.tappedAnimation()
        
        guard cooldownTimer == nil else {
            return
        }
        
        isTappedCheckButton = true
        
        guard let phoneNumber = self.phoneNumberTextField.text else { return }
        checkService.checkBlockUser(userNumber: phoneNumber) { [weak self] isRight in
            guard let self = self else { return }
            
            if isRight {
                showAlert(message: "차단된 번호로는 가입이 불가능합니다..") { [weak self] in
                    guard let self = self else { return }
                    
                    configReset()
                }
            } else {
                checkService.checkPhoneNumber(userNumber: phoneNumber) { [weak self] message, isRight in
                    guard let self = self else { return }
                    
                    guard isRight else {
                        SignLoadingManager.hideLoading()
                        showAlert(message: message) { [weak self] in
                            guard let self = self else { return }
                            
                            viewModel.isRightPhoneNumber = isRight
                            configReset()
                        }
                        return
                    }
                    SignLoadingManager.hideLoading()
                    showAlert(message: "\(phoneNumber)로 인증번호를 전송합니다.") { [weak self] in
                        guard let self = self else { return }
                        
                        cooldownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCooldown), userInfo: nil, repeats: true)
                        RunLoop.main.add(cooldownTimer!, forMode: .common)
                        
                        updateViewState(num: phoneNumber)
                        viewModel.isRightPhoneNumber = isRight
                        smsAuthManager.sendVerificationCode(number: phoneNumber)
                    }
                }
            }
        }
        
    }
    
    @objc private func tappedNextButton(_ sender: UIButton) {
        sender.tappedAnimation()
        configAuthText()
        guard smsAuthManager.checkRightCode(code: authText) else {
            self.showAlert(message: "인증번호를 다시 확인해주세요.", yesAction: nil)
            return
        }
        self.showAlert(message: "인증에 성공하셨습니다.") { [weak self] in
            guard let self = self else { return }
            
            let viewController = SignUpGenderViewController(viewModel: self.viewModel)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
extension SignUpPhoneNumberViewController: UIGestureRecognizerDelegate {
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
        if let view = touch.view as? UIButton {
            return false
        }
        return true
    }
}
// MARK: - 텍스트필드 관련
extension SignUpPhoneNumberViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard isTappedCheckButton else {
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
                authTextFields[currentIndex + 1].becomeFirstResponder()
            }
        }
        return true
    }
}
// MARK: - UI 관련
extension SignUpPhoneNumberViewController {
    
    private func addSubViews() {
        configAuthTextField()
        for pmStkItem in authTextFields {
            authTextFieldStack.addArrangedSubview(pmStkItem)
        }
        
        for stackViewItem in [phoneNumberTextField, cancelButton, authButton] {
            phoneTextFieldstackView.addArrangedSubview(stackViewItem)
        }
        for viewItem in [notifyLabel, progressView, phoneTextFieldstackView, nextButton, authTextFieldStack] {
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
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(SignView.progressViewTopPadding)
            make.leading.equalTo(SignView.padding)
            make.trailing.equalTo(-SignView.padding)
            make.height.equalTo(8)
        }
        
        notifyLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(SignView.padding)
            make.leading.equalTo(SignView.padding)
            make.trailing.equalTo(-SignView.padding)
        }
        
        phoneTextFieldstackView.snp.makeConstraints { make in
            make.top.equalTo(notifyLabel.snp.bottom).offset(SignView.contentPadding)
            make.leading.equalTo(SignView.contentPadding)
            make.trailing.equalTo(-SignView.contentPadding)
            make.height.equalTo(30)
        }
        
        authButton.snp.makeConstraints { make in
            make.width.equalTo(60)
        }
        
        authTextFieldStack.snp.makeConstraints { make in
            make.top.equalTo(phoneTextFieldstackView.snp.bottom).offset(SignView.contentPadding)
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
