//
//  SingUpPhoneNumberViewController.swift
//  Pico
//
//  Created by LJh on 2023/09/26.
//

import UIKit

final class SignUpPhoneNumberViewController: UIViewController {

    private var isFullPhoneNumber: Bool = false
    private var isTappedCheckButton: Bool = false
    private var messageButtons: [UIButton] = []
    private let notifyLabel: UILabel = {
        let label = UILabel()
        label.text = "가입하신 전화번호를 입력하세요."
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
        view.layer.cornerRadius = 5
        return view
    }()
    
    private let phoneTextFieldstackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
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
    
    private lazy var phoneNumberCheckButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("  인증  ", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        button.layer.cornerRadius = 13
        button.setTitleColor(.picoFontBlack, for: .normal)
        button.addTarget(self, action: #selector(tappedPhoneNumberCheckButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var phoneNumberCancleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "x.circle"), for: .normal)
        button.tintColor = .black
        button.imageView?.contentMode = .scaleAspectFit
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight:
                .bold)
        button.addTarget(self, action: #selector(tappedPhoneNumberCancleButton), for: .touchUpInside)
        return button
    }()
    
    private let phoneMessageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.isHidden = true
        return stackView
    }()
    
    private lazy var nextButton: UIButton = {
        let button = CommonButton(type: .custom)
        button.setTitle("다음", for: .normal)
        button.backgroundColor = .picoGray
        button.addTarget(self, action: #selector(tappedNextButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addSubViews()
        makeConstraints()
        phoneNumberTextField.delegate = self
        configBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        followKeyboard()
        phoneNumberTextField.becomeFirstResponder()
    }
    
    // MARK: - Config
    private func configPhonetextFieldAndNextButton(isFull: Bool, isCheck: Bool = false) {
        if isFull {
            phoneNumberTextField.textColor = .picoBlue
        } else {
            phoneNumberTextField.textColor = .picoFontBlack
            nextButton.backgroundColor = .picoGray
        }
        if isCheck {
            phoneMessageStackView.isHidden = false
            phoneNumberTextField.textColor = .picoBlue
            nextButton.backgroundColor = .picoBlue
        } else {
            phoneMessageStackView.isHidden = true
        }
    }
    
    // MARK: - Tapped
    @objc private func tappedPhoneNumberCheckButton(_ sender: UIButton) {
        if isFullPhoneNumber {
            tappedButtonAnimation(sender)
            isTappedCheckButton = true
            configPhonetextFieldAndNextButton(isFull: isFullPhoneNumber, isCheck: isTappedCheckButton)
        }
    }
    @objc private func tappedPhoneNumberCancleButton(_ sender: UIButton) {
        tappedButtonAnimation(sender)
        isFullPhoneNumber = false
        phoneNumberTextField.text = ""
        configPhonetextFieldAndNextButton(isFull: isFullPhoneNumber)
    }
    
    @objc private func tappedNextButton(_ sender: UIButton) {
        if isFullPhoneNumber && isTappedCheckButton {
            tappedButtonAnimation(sender)
            let viewController = SignUpGenderViewController()
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
}

// MARK: - 텍스트필드 관련
extension SignUpPhoneNumberViewController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        phoneNumberTextField.resignFirstResponder()
        self.view.endEditing(true)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.isEmpty {
            isFullPhoneNumber = false
            configPhonetextFieldAndNextButton(isFull: isFullPhoneNumber)
        }
        
        let currentText = (textField.text ?? "") as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        let digits = CharacterSet.decimalDigits
        let filteredText = updatedText.components(separatedBy: digits.inverted).joined()
        
        isFullPhoneNumber = false
        configPhonetextFieldAndNextButton(isFull: isFullPhoneNumber)
        
        if filteredText.count > 11 {
            isFullPhoneNumber = true
            configPhonetextFieldAndNextButton(isFull: isFullPhoneNumber)
            return false
        } else if filteredText.count > 10 {
            isFullPhoneNumber = true
            configPhonetextFieldAndNextButton(isFull: isFullPhoneNumber)
            return true
        }
        
        textField.text = formattedTextFieldText(filteredText)
        return false
    }
    
    func formattedTextFieldText(_ filteredText: String) -> String {
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
extension SignUpPhoneNumberViewController {
    
    private func followKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardUp(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            UIView.animate(
                withDuration: 0.5
                , animations: {
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
        configMessageButtons()
        for pmStkItem in messageButtons {
            phoneMessageStackView.addArrangedSubview(pmStkItem)
        }
        
        for stackViewItem in [phoneNumberTextField, phoneNumberCheckButton, phoneNumberCancleButton] {
            phoneTextFieldstackView.addArrangedSubview(stackViewItem)
        }
        for viewItem in [notifyLabel, progressView, phoneTextFieldstackView, nextButton, phoneMessageStackView] {
            view.addSubview(viewItem)
        }
    }
    
    private func configMessageButtons() {
        for tag in 0...5 {
            let button = UIButton()
            button.titleLabel?.font = .systemFont(ofSize: 25, weight: .bold)
            button.setTitleColor(.picoFontBlack, for: .normal)
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 10
            button.tag = tag
            button.clipsToBounds = true
            messageButtons.append(button)
        }
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(10)
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
            make.height.equalTo(8)
        }
        
        notifyLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(10)
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
            make.height.equalTo(50)
        }
        
        phoneTextFieldstackView.snp.makeConstraints { make in
            make.top.equalTo(notifyLabel.snp.bottom).offset(10)
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
            make.height.equalTo(50)
        }
        
        phoneMessageStackView.snp.makeConstraints { make in
            make.top.equalTo(phoneTextFieldstackView.snp.bottom).offset(20)
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
            make.height.equalTo(50)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.bottom.equalTo(safeArea).offset(-30)
            make.height.equalTo(50)
        }
    }
}
