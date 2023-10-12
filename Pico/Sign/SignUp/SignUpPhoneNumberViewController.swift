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
    var viewModel: SignUpViewModel = .shared
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
    
    private let cancleButton: UIButton = {
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
        registerKeyboard()
        phoneNumberTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboard()
    }
}
// MARK: - Config
extension SignUpPhoneNumberViewController {
  
    private func configButtons() {
        authButton.addTarget(self, action: #selector(tappedCheckButton), for: .touchUpInside)
        cancleButton.addTarget(self, action: #selector(tappedCancleButton), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(tappedNextButton), for: .touchUpInside)
    }
    
    private func configTextField() {
        phoneNumberTextField.delegate = self
    }
    
    func configAuthText() {
        var authStrings: [String] = []
        for text in authTextFields {
            authStrings.append(text.text ?? "")
        }
        self.authText = authStrings.joined()
        print(authText)
        // 임시로 넘어가게 함
        self.isAuth = true
    }
    
    private func configReset() {
        // 초기상태로 가는거임
        self.registerKeyboard()
        self.phoneNumberTextField.becomeFirstResponder()
        self.phoneNumberTextField.text = ""
        self.userPhoneNumber = ""
        self.isFullPhoneNumber = false
        self.isTappedCheckButton = false
        self.updatePhoneNumberTextField(isTrue: false)
        self.updateCancleButton(isTrue: false)
        self.updateAuthButton(isFull: false)
        self.updateNextButton(isCheck: false)
        self.updateAuthTextFieldStack(false)
    }
    
    // MARK: - Update 관련 Number, cancle, auth, authField, next
    private func updatePhoneNumberTextField(isTrue: Bool) {
        switch isTrue {
        case true:
            self.phoneNumberTextField.isEnabled = false
            self.phoneNumberTextField.textColor = .picoBlue
        case false:
            self.phoneNumberTextField.isEnabled = true
            self.phoneNumberTextField.textColor = .gray
        }
    }

    private func updateCancleButton(isTrue: Bool) {
        switch isTrue {
        case true:
            self.cancleButton.isHidden = true
        case false:
            self.cancleButton.isHidden = false
        }
    }
    
    private func updateAuthButton(isFull: Bool, isHidden: Bool = false) {
        switch isFull {
        case true:
            authButton.isEnabled = true
            authButton.backgroundColor = .picoBlue
            authButton.isHidden = false
            isFullPhoneNumber = true
            print("updateCheckButton: 트루")
        case false:
            authButton.isEnabled = false
            authButton.backgroundColor = .picoGray
            authButton.isHidden = isHidden
            isFullPhoneNumber = false
            print("updateCheckButton: false")
        }
    }
    
    private func updateAuthTextFieldStack(_ isTrue: Bool) {
        switch isTrue {
        case true:
            authTextFieldStack.isHidden = false
        case false:
            authTextFieldStack.isHidden = true
        }
    }
    
    private func updateNextButton(isCheck: Bool) {
        switch isCheck {
        case true:
            nextButton.backgroundColor = .picoBlue
        case false:
            nextButton.backgroundColor = .picoGray
        }
    }
    // MARK: - @objc
    @objc private func tappedCancleButton(_ sender: UIButton) {
        sender.tappedAnimation()
        phoneNumberTextField.text = ""
        updateAuthButton(isFull: false)
    }
    
    @objc private func tappedCheckButton(_ sender: UIButton) {
        sender.tappedAnimation()
        isTappedCheckButton = true
        showAlert(message: "\(phoneNumberTextField.text ?? "") 번호로 인증번호를 전송합니다.", isCancelButton: true) {
            
            self.updatePhoneNumberTextField(isTrue: true)
            self.updateCancleButton(isTrue: true)
            self.updateAuthButton(isFull: false, isHidden: false)
            self.updateAuthTextFieldStack(true)
            print("isFullPhoneNumber : \(self.isFullPhoneNumber)\nisTappedCheckButton : \(self.isTappedCheckButton) ")
            // MARK: - 문자인증 시작하면 건드려야해용
//            self.updateNextButton(isCheck: true)
            
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
            }
        }
    }
   
    @objc private func tappedNextButton(_ sender: UIButton) {
        guard isFullPhoneNumber && isTappedCheckButton else { return }
        sender.tappedAnimation()
        // MARK: - 문자인증 시작하면 건드려야해용
        // 이자리에 isAuth를 변경시켜줄 인증 함수를 넣어야함
        configAuthText()
        guard isAuth else {
            self.showAlert(message: "비상비상 인증실패") { self.configReset() }
            return
        }
        self.showAlert(message: "인증에 성공하셨습니다.") {
            let viewController = SignUpGenderViewController()
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
}
// MARK: - 텍스트필드 관련
extension SignUpPhoneNumberViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard isTappedCheckButton else {
            let isChangeValue = changePhoneNumDigits(textField, shouldChangeCharactersIn: range, replacementString: string) { isFull in
                updateAuthButton(isFull: isFull, isHidden: true)
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

// MARK: - 키보드 관련
extension SignUpPhoneNumberViewController {
    
    private func registerKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func unregisterKeyboard() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardUp(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            
            UIView.animate(
                withDuration: 0.5,
                animations: {
                    self.nextButton.transform = CGAffineTransform(translationX: 0, y: -keyboardRectangle.height + 50)
                }
            )
        }
    }
    
    @objc private func keyboardDown() {
        self.nextButton.transform = .identity
    }
}

// MARK: - UI 관련
extension SignUpPhoneNumberViewController {
    
    private func addSubViews() {
        configAuthTextField()
        for pmStkItem in authTextFields {
            authTextFieldStack.addArrangedSubview(pmStkItem)
        }
        
        for stackViewItem in [phoneNumberTextField, cancleButton, authButton] {
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
