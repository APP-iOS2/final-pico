//
//  SignUpGenderViewController.swift
//  Pico
//
//  Created by LJh on 2023/09/26.
//

import UIKit
import SnapKit

final class SignUpGenderViewController: UIViewController {
    private var gender: String = ""
    private var genderButtons: [UIButton] = []
    private var isTappedGenderButton = false
    let viewModel: SignUpViewModel
    
    init(viewModel: SignUpViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = .picoGray
        view.progressTintColor = .picoBlue
        view.layer.cornerRadius = SignView.progressViewCornerRadius
        view.layer.masksToBounds = true
        view.progress = viewModel.progressStatus
        return view
    }()
    
    private let notifyLabel: UILabel = {
        let label = UILabel()
        label.text = "성별을 알려주세요"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.picoTitleFont
        return label
    }()
    
    private let subNotifyLabel: UILabel = {
        let label = UILabel()
        label.text = "⭐️ 신중하게 골라주세요.\n성별은변경이 불가능합니다."
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.textColor = .picoFontGray
        label.font = UIFont.picoDescriptionFont
        return label
    }()
    
    private let buttonVerticalStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        return stackView
    }()

    private lazy var manButton: UIButton = configGenderButtons(title: "남자")
    private lazy var girlButton: UIButton = configGenderButtons(title: "여자")
    private lazy var otherButton: UIButton = configGenderButtons(title: "기타")
    
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
        view.configBackgroundColor(color: .white)
        configNavigationBackButton()
        addSubViews()
        makeConstraints()
    }
    override func viewDidAppear(_ animated: Bool) {
        viewModel.animateProgressBar(progressView: progressView, endPoint: 3)
    }
}
// MARK: - Config
extension SignUpGenderViewController {
    private func configNextButton() {
        isTappedGenderButton = true
        nextButton.backgroundColor = .picoBlue
    }
    
    private func configGenderButtons(title: String) -> UIButton {
        let button = UIButton()
        button.backgroundColor = .picoGray
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .picoButtonFont
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.setTitleColor(.picoFontBlack, for: .normal)
        button.addTarget(self, action: #selector(tappedGenderButton), for: .touchUpInside)
        return button
    }
    
    // MARK: - @@objc
    @objc private func tappedNextButton(_ sender: UIButton) {
        if isTappedGenderButton {
            sender.tappedAnimation()
            
            let viewController = SignUpAgeViewController(viewModel: viewModel)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @objc private func tappedGenderButton(_ sender: UIButton) {
        sender.tappedAnimation()
        configNextButton()
        for button in genderButtons {
            button.isSelected = (button == sender)
            guard let text = sender.titleLabel?.text else { return }
            switch button.isSelected {
            case true:
                sender.backgroundColor = .picoAlphaBlue
                sender.setTitleColor(.white, for: .normal)
                gender = text
                configGender()
            case false:
                button.backgroundColor = .picoGray
                button.setTitleColor(.black, for: .normal)
            }
        }
    }
    func configGender() {
        switch gender {
        case "남자":
                viewModel.gender = .male
        case "여자":
                viewModel.gender = .female
        case "기타":
                viewModel.gender = .etc
        default:
            return
        }
    }
}
// MARK: - UI 관련
extension SignUpGenderViewController {
    
    private func addSubViews() {
        for gender in [manButton, girlButton, otherButton] {
            genderButtons.append(gender)
        }
        for stackViewItem in genderButtons {
            buttonVerticalStack.addArrangedSubview(stackViewItem)
        }
        for viewItem in [progressView, notifyLabel, subNotifyLabel, buttonVerticalStack, nextButton] {
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
        
        buttonVerticalStack.snp.makeConstraints { make in
            make.top.equalTo(subNotifyLabel.snp.bottom).offset(SignView.contentPadding)
            make.leading.equalTo(SignView.contentPadding)
            make.trailing.equalTo(-SignView.contentPadding)
            make.height.equalTo(200)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.equalTo(notifyLabel.snp.leading)
            make.trailing.equalTo(notifyLabel.snp.trailing)
            make.bottom.equalTo(safeArea).offset(SignView.bottomPadding)
            make.height.equalTo(CommonConstraints.buttonHeight)
        }
    }
}
