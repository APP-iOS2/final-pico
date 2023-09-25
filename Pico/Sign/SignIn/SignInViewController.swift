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
        // tf.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        return textField
    }()
    
    private let phoneNumberCancleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "x.circle"), for: .normal)
        button.tintColor = .black
        button.imageView?.contentMode = .scaleAspectFit
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        //        button.addTarget(self, action: #selector(tappedSignInButton), for: .touchUpInside)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addSubViews()
        makeConstraints()
        configTextfield()
    }
    
    private func configTextfield() {
        phoneNumberTextField.delegate = self
    }
    
    private func addSubViews() {
        view.addSubview(notifyLabel)
        view.addSubview(stackView)
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
            make.trailing.equalToSuperview().offset(-20)
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
        if Int(string) != nil || string == "" {
            if (textField.text?.count)! > 10 {
                phoneNumberTextField.textColor = .black
                return false
            } else {
                
                return true
            }
        }
        return false
    }
}
