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
    private let authManager = SMSAuthService()
    private let keyboardManager = KeyboardService()
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
        textField.accessibilityHint = "전화번호를 입력하는 텍스트필드"
        return textField
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        let image = UIImage(systemName: "x.circle", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .picoGray
        button.accessibilityHint = "전화번호를 지우는 버튼"
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
        button.accessibilityHint = "전화번호를 인증하는 버튼"
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
        view.configBackgroundColor(color: .systemBackground)        
        tappedDismissKeyboard(without: [nextButton])
        addSubViews()
        makeConstraints()
        configTextfield()
        configButton()
        configAuthTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardManager.registerKeyboard(with: nextButton)
        phoneNumberTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        keyboardManager.unregisterKeyboard()
        configReset()
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
                view.endEditing(true)
                authButton.tappedAnimation()
                guard isFullPhoneNumber else { return }
                guard let phoneNumber = phoneNumberTextField.text else { return }
                
                guard cooldownTimer == nil else {
                    return
                }
          
                viewModel.signIn(userNumber: phoneNumber) { [weak self] _, message in
                    guard let self = self else { return }
                    
                    guard viewModel.isRightUser else {
                        checkService.checkBlockUser(userNumber: phoneNumber) { [weak self] isBlock in
                            guard let self = self else { return }
                            
                            if isBlock {
                                Loading.hideLoading()
                                showCustomAlert(alertType: .onlyConfirm, titleText: "알림", messageText: "탈퇴한 회원입니다.", confirmButtonText: "확인", comfrimAction: configReset)
                                return
                            } else {
                                Loading.hideLoading()
                                showCustomAlert(alertType: .onlyConfirm, titleText: "알림", messageText: message, confirmButtonText: "확인", comfrimAction: configReset)
                                return
                            }
                        }
                        
                        checkService.checkStopUser(userNumber: phoneNumber) { [weak self] isStop, stop in
                            guard let self = self else { return }
                            guard isStop else { return }
                            let currentDate = Date()
                            let stopDate = Date(timeIntervalSince1970: stop.createdDate)
                            let stopDuring = stop.during
                            let stopUser = stop.user
                          
                            if let resumedDate = Calendar.current.date(byAdding: .day, value: stopDuring, to: stopDate) {
                                if currentDate > resumedDate {
                                    Loading.hideLoading()
                                    
                                    FirestoreService.shared.saveDocument(collectionId: .users, documentId: stopUser.id, data: stopUser) { _ in }

                                    showCustomAlert(alertType: .onlyConfirm, titleText: "알림", messageText: "정지가 풀렸습니다. 열심히 살아주세요 ㅎㅎ", confirmButtonText: "확인", comfrimAction: configReset)
                                    
                                    FirestoreService.shared.deleteDocument(collectionId: .stop, field: "phoneNumber", isEqualto: phoneNumber)

                                } else {
                                    Loading.hideLoading()
                                    showCustomAlert(alertType: .onlyConfirm, titleText: "알림", messageText: "\(stop.during)일 정지된 대상입니다.", confirmButtonText: "확인", comfrimAction: configReset)
                                }
                            } else {
                                print("날짜 계산 중에 오류가 발생했습니다.")
                                return
                            }
                        }
                    return
                }
                    Loading.hideLoading()
                    showCustomAlert(alertType: .onlyConfirm, titleText: "알림", messageText: "인증번호를 전송했습니다.", confirmButtonText: "확인", comfrimAction: { [weak self] in
                        guard let self = self else { return }
                        
                        cooldownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCooldown), userInfo: nil, repeats: true)
                        RunLoop.main.add(cooldownTimer!, forMode: .common)
                        
                        configTappedAuthButtonState()
                        authManager.sendVerificationCode(phoneNumber: phoneNumber)
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
                
                view.endEditing(true)
                configAuthText()
                
                guard authManager.checkRightCode(code: authText) else {
                    showCustomAlert(alertType: .onlyConfirm, titleText: "경고", messageText: "인증번호가 일치하지 않습니다.\n다시 확인해주세요.", confirmButtonText: "확인")
                    return
                }
                
                showCustomAlert(alertType: .onlyConfirm, titleText: "알림", messageText: "인증에 성공하셨습니다.", confirmButtonText: "확인", comfrimAction: { [weak self] in
                    guard let self = self else { return }
                    guard let number = phoneNumberTextField.text else { return }
                    
                    FirestoreService.shared.loadDocument(collectionId: .session, documentId: number, dataType: User.self) { [weak self] result in
                        guard let self = self else { return }
                        
                        switch result {
                        case .success(let user):
                            guard user != nil else { return }
                            showCustomAlert(alertType: .onlyConfirm, titleText: "경고", messageText: "다른기기에서 접속중입니다.", confirmButtonText: "확인", comfrimAction: { [weak self] in
                                guard let self = self else { return }
                                navigationController?.popViewController(animated: true)
                            })
                        case .failure(let err):
                            print("SingInVIewController 세션부분 에러입니다. error: \(err) ")
                        }
                    }
                    
                    guard let user = viewModel.loginUser else {
                        showCustomAlert(alertType: .onlyConfirm, titleText: "경고", messageText: "로그인에 실패하셨습니다.", confirmButtonText: "확인")
                        return
                    }
                    let viewController = LoginSuccessViewController(user: user)
                    self.navigationController?.pushViewController(viewController, animated: true)
                })
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
            textField.accessibilityHint = "인증번호를 받는 텍스트필드"
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
