//
//  SignUpNickNameViewController.swift
//  Pico
//
//  Created by LJh on 2023/09/27.
//

import UIKit
import SnapKit

final class SignUpNickNameViewController: UIViewController {
    private let keyboardManager = KeyboardManager()
    private let viewModel: SignUpViewModel
    private let checkNickNameService = CheckService()
    init(viewModel: SignUpViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private let minNickNameWordCount: Int = 2
    private let maxNickNameWordCount: Int = 8
    private var isCheckNickName: Bool = false
    private var userNickName: String = ""
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = .lightGray
        view.progressTintColor = .picoBlue
        view.layer.cornerRadius = SignView.progressViewCornerRadius
        view.layer.masksToBounds = true
        view.progress = viewModel.progressStatus
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
        label.text = "신중하게 정해주세요😁(추후 변경은 유료)"
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.textColor = .picoFontGray
        label.font = UIFont.picoDescriptionFont
        return label
    }()
    
    private let nickNameHorizontalStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var nickNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "3자리 부터 8자리 까지"
        textField.font = .picoTitleFont
        textField.textColor = .gray
        return textField
    }()
    
    private let nickNameCheckButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("  중복확인  ", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 13
        button.backgroundColor = .picoBlue
        button.isHidden = true
        return button
    }()
    
    private lazy var nickNameCancleButton: UIButton = {
        let button = UIButton(type: .custom)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        let image = UIImage(systemName: "x.circle", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .picoGray
        return button
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
    override func viewDidAppear(_ animated: Bool) {
        viewModel.animateProgressBar(progressView: progressView, endPoint: 5)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardManager.registerKeyboard(with: nextButton)
        nickNameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardManager.unregisterKeyboard()
    }
}
// MARK: - Config
extension SignUpNickNameViewController {
    private func configButtons() {
        nickNameCheckButton.addTarget(self, action: #selector(tappedCheckButton), for: .touchUpInside)
        nickNameCancleButton.addTarget(self, action: #selector(tappedNickNameCancleButton), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(tappedNextButton), for: .touchUpInside)
    }
    
    private func configTextField() {
        nickNameTextField.delegate = self
        nickNameTextField.becomeFirstResponder()
    }
    
    private func updateCheckButton(isFull: Bool, ischeck: Bool = false) {
        switch isFull {
        case true:
            nickNameCheckButton.isHidden = false
        case false:
            nickNameCheckButton.isHidden = true
        }
        switch ischeck {
        case true:
            nickNameCheckButton.backgroundColor = .picoGray
        case false:
            nickNameCheckButton.backgroundColor = .picoBlue
        }
    }
    
    private func updateNextButton(isCheck: Bool) {
        switch isCheck {
        case true:
            nextButton.backgroundColor = .picoBlue
            nextButton.isEnabled = true
            isCheckNickName = true
        case false:
            nextButton.backgroundColor = .picoGray
            nextButton.isEnabled = false
            isCheckNickName = false
        }
    }
    
    private func reset() {
        nickNameTextField.text = ""
        nickNameCancleButton.isEnabled = true
        nickNameTextField.isEnabled = true
        nickNameTextField.becomeFirstResponder()
        updateCheckButton(isFull: false)
        updateNextButton(isCheck: false)
    }
    // MARK: - @objc
    @objc private func tappedCheckButton(_ sender: UIButton) {
        sender.tappedAnimation()
        guard let userNickName = nickNameTextField.text?.replacingOccurrences(of: " ", with: "") else { return }
        
        showCustomAlert(alertType: .onlyConfirm, titleText: "알림", messageText: "\(userNickName) 이름으로 설정합니다.", confirmButtonText: "확인", comfrimAction: { [weak self] in
            guard let self = self else { return }
            checkNickNameService.checkNickName(name: userNickName) { [weak self] message, isRight in
                guard let self = self else { return }
                
                SignLoadingManager.hideLoading()
                guard isRight else {
                    showCustomAlert(alertType: .onlyConfirm, titleText: "알림", messageText: message, confirmButtonText: "확인", comfrimAction: { [weak self] in
                        guard let self = self else { return }
                        
                        viewModel.isRightName = isRight
                        reset()
                    })
                    return
                }
                showCustomAlert(alertType: .onlyConfirm, titleText: "알림", messageText: message, confirmButtonText: "확인", comfrimAction: { [weak self] in
                    guard let self = self else { return }
                    
                    viewModel.isRightName = isRight
                    self.userNickName = userNickName
                })
            }
            updateCheckButton(isFull: true, ischeck: true)
            updateNextButton(isCheck: true)
            nickNameTextField.textColor = .picoBlue
            
        })
    }
    
    @objc private func tappedNickNameCancleButton(_ sender: UIButton) {
        sender.tappedAnimation()
        nickNameTextField.text = ""
        nickNameTextField.textColor = .gray
        updateCheckButton(isFull: false)
    }
    
    @objc private func tappedNextButton(_ sender: UIButton) {
        viewModel.nickName = userNickName
        let viewController = SignUpPictureViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - 텍스트 필드 관련
extension SignUpNickNameViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            return false
        }
        let currentText = textField.text ?? ""
        var newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        newText = newText.replacingOccurrences(of: " ", with: "")
        updateCheckButton(isFull: false)
        
        if newText.count > minNickNameWordCount {
            updateCheckButton(isFull: true)
        }
        
        return newText.count <= maxNickNameWordCount
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
// MARK: - UI 관련
extension SignUpNickNameViewController {
    
    private func addSubViews() {
        for stackViewItem in [nickNameTextField, nickNameCancleButton, nickNameCheckButton] {
            nickNameHorizontalStack.addArrangedSubview(stackViewItem)
        }
        
        for viewItem in [progressView, notifyLabel, subNotifyLabel, nickNameHorizontalStack, nextButton] {
            view.addSubview(viewItem)
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
        
        subNotifyLabel.snp.makeConstraints { make in
            make.top.equalTo(notifyLabel.snp.bottom).offset(SignView.subPadding)
            make.leading.equalTo(notifyLabel.snp.leading)
            make.trailing.equalTo(notifyLabel.snp.trailing)
        }
        
        nickNameHorizontalStack.snp.makeConstraints { make in
            make.top.equalTo(subNotifyLabel.snp.bottom).offset(SignView.contentPadding)
            make.leading.equalTo(SignView.contentPadding)
            make.trailing.equalTo(-SignView.contentPadding)
            make.height.equalTo(30)
        }
        
        nickNameCheckButton.snp.makeConstraints { make in
            make.width.equalTo(80)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.equalTo(notifyLabel.snp.leading)
            make.trailing.equalTo(notifyLabel.snp.trailing)
            make.bottom.equalTo(safeArea).offset(SignView.bottomPadding)
            make.height.equalTo(CommonConstraints.buttonHeight)
        }
    }
}
