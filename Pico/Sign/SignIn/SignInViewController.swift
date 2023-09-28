//
//  SignInViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import SnapKit

final class SignInViewController: UIViewController {
    
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
    
    private let stackView: UIStackView = {
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
        view.backgroundColor = .systemBackground
        addSubViews()
        makeConstraints()
        configTextfield()
        configButtons()
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
    
    // MARK: - Config
    private func configTextfield() {
        phoneNumberTextField.delegate = self
    }
    
    private func configButtons() {
        phoneNumberCancleButton.addTarget(self, action: #selector(tappedPhoneNumberCancleButton), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(tappedNextButton), for: .touchUpInside)
    }
    
    @objc private func tappedPhoneNumberCancleButton(_ sender: UIButton) {
        tappedButtonAnimation(sender)
        phoneNumberTextField.text = ""
        changeViewState(isFull: false)
    }
    
    @objc private func tappedNextButton(_ sender: UIButton) {
        tappedButtonAnimation(sender)
        if isFullPhoneNumber {
            let viewController = LoginSuccessViewController()
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    private func changeViewState(isFull: Bool) {
        if isFull {
            phoneNumberTextField.textColor = .picoBlue
            nextButton.backgroundColor = .picoBlue
            isFullPhoneNumber = true
        } else {
            phoneNumberTextField.textColor = .gray
            nextButton.backgroundColor = .picoGray
            isFullPhoneNumber = false
        }
    }
}

// MARK: - 텍스트필드 관련
extension SignInViewController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        phoneNumberTextField.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "") as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        let digits = CharacterSet.decimalDigits
        let filteredText = updatedText.components(separatedBy: digits.inverted).joined()
        
        if filteredText.count < 11 {
            changeViewState(isFull: false)
        } else {
            changeViewState(isFull: true)
        }
        
        textField.text = formattedTextFieldText(filteredText)
        return filteredText.count < 12
    }
    
    private func formattedTextFieldText(_ filteredText: String) -> String {
        let formattedText: String
        
        if filteredText.count <= 3 {
            formattedText = filteredText
        } else if filteredText.count <= 7 {
            let firstPart = filteredText.prefix(3)
            let secondPart = filteredText.dropFirst(3).prefix(4)
            formattedText = "\(firstPart)-\(secondPart)"
        } else {
            let firstPart = filteredText.prefix(3)
            let secondPart = filteredText.dropFirst(3).prefix(4)
            let thirdPart = filteredText.dropFirst(7).prefix(4)
            formattedText = "\(firstPart)-\(secondPart)-\(thirdPart)"
        }
        
        return formattedText
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
            stackView.addArrangedSubview(stackViewItem)
        }
        
        for viewItem in [notifyLabel, stackView, nextButton] {
            view.addSubview(viewItem)
        }
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        notifyLabel.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(10)
            make.leading.equalToSuperview().offset(Constraint.SignView.padding)
            make.trailing.equalToSuperview().offset(-Constraint.SignView.padding)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(notifyLabel.snp.bottom).offset(Constraint.SignView.contentPadding)
            make.leading.equalToSuperview().offset(Constraint.SignView.contentPadding)
            make.trailing.equalToSuperview().offset(-Constraint.SignView.contentPadding)
            make.height.equalTo(50)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.equalTo(notifyLabel.snp.leading)
            make.trailing.equalTo(notifyLabel.snp.trailing)
            make.bottom.equalTo(safeArea).offset(Constraint.SignView.bottomPadding)
            make.height.equalTo(Constraint.Button.commonHeight)
        }
    }
}
