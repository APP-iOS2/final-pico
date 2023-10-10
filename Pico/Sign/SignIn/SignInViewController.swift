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
    
    private let viewModel = SignInViewModel()
    private let disposeBag = DisposeBag()
    private let phoneNumberSubject = BehaviorSubject<String>(value: "")
    private var isFullPhoneNumber: Bool = false
    
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
    
    private let phoneNumberCancleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "x.circle"), for: .normal)
        button.tintColor = .black
        button.imageView?.contentMode = .scaleAspectFit
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
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
    
    private let nextButton: UIButton = {
        let button = CommonButton(type: .custom)
        button.setTitle("다음", for: .normal)
        button.backgroundColor = .picoGray
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
extension SignInViewController {
    private func configTextfield() {
        phoneNumberTextField.delegate = self
    }
    
    private func configButton() {
        nextButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                nextButton.tappedAnimation()
                guard self.isFullPhoneNumber else { return }
                guard let text = self.phoneNumberTextField.text else { return }
                viewModel.signIn(userNumber: text) { user in
                    if self.viewModel.isRightUser {
                        Loading.hideLoading()
                        if let user = user {
                            UserDefaultsManager.shared.setUserData(userData: user)
                            let viewController = LoginSuccessViewController()
                            self.navigationController?.pushViewController(viewController, animated: true)
                        }
                    } else {
                        Loading.hideLoading()
                        self.showAlert(message: "등록되지 않은 번호입니다.") {
                            self.phoneNumberTextField.text = ""
                        }
                    }
                }
                print(viewModel.loginUser, separator: ",")
            })
            .disposed(by: disposeBag)
        
        phoneNumberCancleButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                print("phoneNumberCancleButton")
                phoneNumberCancleButton.tappedAnimation()
                self.phoneNumberTextField.text = ""
                changeViewState(isFull: false)
            })
            .disposed(by: disposeBag)
    }
    
    private func changeViewState(isFull: Bool) {
        switch isFull {
        case true:
            phoneNumberTextField.textColor = .picoBlue
            nextButton.backgroundColor = .picoBlue
            isFullPhoneNumber = true
        case false:
            phoneNumberTextField.textColor = .gray
            nextButton.backgroundColor = .picoGray
            isFullPhoneNumber = false
        }
    }
}
// MARK: - 텍스트필드 관련
extension SignInViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let isChangeValue = changePhoneNumDigits(textField, shouldChangeCharactersIn: range, replacementString: string) { isFull in
            changeViewState(isFull: isFull)
        }
        
        return isChangeValue
    }
}

// MARK: - 키보드 관련
extension SignInViewController {
    
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
extension SignInViewController {
    
    private func addSubViews() {
        for stackViewItem in [phoneNumberTextField, phoneNumberCancleButton] {
            buttonHorizontalStack.addArrangedSubview(stackViewItem)
        }
        
        for viewItem in [notifyLabel, buttonHorizontalStack, nextButton] {
            view.addSubview(viewItem)
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
