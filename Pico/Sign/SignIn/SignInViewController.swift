//
//  SignInViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import SnapKit

final class SignInViewController: UIViewController {
    
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
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.addArrangedSubview(phoneNumberTextField)
        stackView.addArrangedSubview(phoneNumberCancleButton)
        return stackView
    }()
    
    private let nextButton: UIButton = {
        let button = CommonButton(type: .custom)
        button.setTitle("다음", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addSubViews()
        makeConstraints()
        configTextfield()
        configButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func configTextfield() {
        phoneNumberTextField.delegate = self
    }
    
    private func configButton() {
        phoneNumberCancleButton.addTarget(self, action: #selector(tappedSignInButton), for: .touchUpInside)
    }
    
    @objc private func tappedSignInButton() {
        print(#function)
        phoneNumberTextField.text = ""
    }
    
    @objc private func tappedNextButton() {
        let viewController = LoginSuccessViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
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
    
    private func addSubViews() {
        view.addSubview(notifyLabel)
        view.addSubview(stackView)
        view.addSubview(nextButton)
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        notifyLabel.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(notifyLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-60)
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
        
        textField.textColor = .gray
        if filteredText.count > 11 {
            
            textField.textColor = .picoBlue
            return false
        } else if filteredText.count > 10 {
            textField.textColor = .picoBlue
            return true
        }
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
        
        textField.text = formattedText
        
        return false
    }
}
