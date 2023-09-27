//
//  SignUpNickNameViewController.swift
//  Pico
//
//  Created by LJh on 2023/09/27.
//

import UIKit

class SignUpNickNameViewController: UIViewController {
    
    private let minNickNameWordCount: Int = 2
    private let maxNickNameWordCount: Int = 8
    private var isCheckNickName: Bool = false
    private let progressView: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = .picoBetaBlue
        view.progressTintColor = .picoBlue
        view.progress = 0.142 * 5
        view.layer.cornerRadius = 5
        return view
    }()
    
    private let notifyLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임을 정해주세요"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.picoTitleFont
        return label
    }()
    
    private let subNotifyLabel: UILabel = {
        let label = UILabel()
        label.text = "신중하게 정해주세요😁"
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.textColor = .picoFontGray
        label.font = UIFont.picoDescriptionFont
        return label
    }()
    
    private let nickNameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var nickNameTextField: UITextField = {
        let textField = UITextField()
        return textField
    }()
    
    private lazy var nickNameCancleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "x.circle"), for: .normal)
        button.tintColor = .black
        button.imageView?.contentMode = .scaleAspectFit
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.addTarget(self, action: #selector(tappedNickNameCancleButton), for: .touchUpInside)
        return button
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
        nickNameTextField.delegate = self
        nickNameTextField.becomeFirstResponder()
    }
    override func viewWillAppear(_ animated: Bool) {
        followKeyboard()
    }
}

extension SignUpNickNameViewController {
    // MARK: - Config
    private func configNextButton(isCheck: Bool) {
        if isCheck {
            nextButton.backgroundColor = .picoBlue
            isCheckNickName = true
        } else {
            nextButton.backgroundColor = .picoGray
            isCheckNickName = false
        }
    }
    // MARK: - Tapped
    @objc private func tappedNickNameCancleButton(_ sender: UIButton) {
        tappedButtonAnimation(sender)
        nickNameTextField.text = ""
    }
    
    @objc private func tappedNextButton(_ sender: UIButton) {
        
    }
    
}

// MARK: - 텍스트 필드 관련

extension SignUpNickNameViewController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nickNameTextField.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textCount = textField.text?.count else { return false }
        print(range.length)
        if textCount >= minNickNameWordCount && textCount < maxNickNameWordCount {
            configNextButton(isCheck: true)
            return true
        } else if textCount >= maxNickNameWordCount {
            if string.isEmpty {
                return true
            }
            return false
        } else {
            configNextButton(isCheck: false)
            return true
        }
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
// MARK: - 키보드 관련
extension SignUpNickNameViewController {
    
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
extension SignUpNickNameViewController {
    private func addSubViews() {
        
        for stackViewItem in [nickNameTextField, nickNameCancleButton] {
            nickNameStackView.addArrangedSubview(stackViewItem)
        }
        
        for viewItem in [progressView, notifyLabel, subNotifyLabel, nickNameStackView, nextButton] {
            view.addSubview(viewItem)
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
        
        subNotifyLabel.snp.makeConstraints { make in
            make.top.equalTo(notifyLabel.snp.bottom).offset(-15)
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
            make.height.equalTo(50)
        }
        
        nickNameStackView.snp.makeConstraints { make in
            make.top.equalTo(subNotifyLabel.snp.bottom).offset(5)
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
