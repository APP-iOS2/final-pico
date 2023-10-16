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
    private let authManager = SmsAuthManager()
    let viewModel: SignUpViewModel
    
    init(viewModel: SignUpViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var userPhoneNumber: String = ""
    private var isFullPhoneNumber: Bool = false
    private var isTappedCheckButton: Bool = false
    private var isAuth: Bool = false
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
    
    private let progressView: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = .picoBetaBlue
        view.progressTintColor = .picoBlue
        view.progress = 0.284
        view.layer.cornerRadius = SignView.progressViewCornerRadius
        view.layer.masksToBounds = true
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
        button.setImage(UIImage(systemName: "x.circle"), for: .normal)
        button.tintColor = .black
        button.imageView?.contentMode = .scaleAspectFit
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight:
                .bold)
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
        view.tappedDismissKeyboard()
        configNavigationBackButton()
        addSubViews()
        makeConstraints()
        configButtons()
        configTextField()
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
        isAuth = false
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
    // MARK: - @objc
    @objc private func tappedCancelButton(_ sender: UIButton) {
        sender.tappedAnimation()
        configReset()
    }
    
    @objc private func tappedAuthButton(_ sender: UIButton) {
        sender.tappedAnimation()
        isTappedCheckButton = true
        showAlert(message: "\(phoneNumberTextField.text ?? "") 번호로 인증번호를 전송합니다.") {
            guard let text = self.phoneNumberTextField.text else { return }
            self.viewModel.checkPhoneNumber(userNumber: text) {
                guard self.viewModel.isRightUser else {
                    Loading.hideLoading()
                    self.showAlert(message: "이미 등록된 번호입니다.") {
                        self.configReset()
                    }
                    return
                }
                Loading.hideLoading()
                self.viewModel.phoneNumber = text
                self.authTextFields[0].becomeFirstResponder()
                self.updatePhoneNumberTextField(isFull: true)
                self.updateCancelButton(isHidden: true)
                self.updateAuthButton(isEnable: false, isHidden: false)
                self.updateAuthTextFieldStack(isShow: true)
                self.updateNextButton(isEnabled: true)
            }
        }
    }
    
    @objc private func tappedNextButton(_ sender: UIButton) {
        sender.tappedAnimation()
        // 문자인증 시작하면 건드려야해용
        // 문자인증 기능이 완료 될 때 까지는 넘어가세요 :)
        configAuthText()
        isAuth = true
        authManager.sendVerificationCode()
        guard isAuth else {
            print("비상비상")
            self.showAlert(message: "비상비상 인증실패") { self.configReset() }
            return
        }
        print("성공성공")
        self.showAlert(message: "인증에 성공하셨습니다.") {
            let viewController = SignUpGenderViewController(viewModel: self.viewModel)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
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
