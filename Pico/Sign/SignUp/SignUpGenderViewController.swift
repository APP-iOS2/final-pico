//
//  SignUpGenderViewController.swift
//  Pico
//
//  Created by LJh on 2023/09/26.
//

import UIKit

class SignUpGenderViewController: UIViewController {
    
    private var gender: String = ""
    private var genderButtons: [UIButton] = []
   
    private let progressView: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = .picoBetaBlue
        view.progressTintColor = .picoBlue
        view.progress = 0.284
        view.layer.cornerRadius = 5
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
    
    private let stackView: UIStackView = {
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
    
    private let nextButton: UIButton = {
        let button = CommonButton(type: .custom)
        button.setTitle("다음", for: .normal)
        return button
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addSubViews()
        makeConstraints()
        configButton()
    }
    
    // MARK: - config
    private func configButton() {
        nextButton.addTarget(self, action: #selector(tappedNextButton), for: .touchUpInside)
    }
    
    @objc private func tappedNextButton(_ sender: UIButton) {
        tappedGenderButton(sender)
    }
    
    @objc func tappedGenderButton(_ sender: UIButton) {
        tappedButtonAnimation(sender)
        
        for button in genderButtons {
            button.isSelected = (button == sender)
            guard let text = sender.titleLabel?.text else { return }
            if button.isSelected {
                sender.backgroundColor = .picoAlphaBlue
                sender.setTitleColor(.white, for: .normal)
                gender = text
            } else {
                button.backgroundColor = .picoGray
                button.setTitleColor(.black, for: .normal)
            }
        }
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
    
    // MARK: - UI 관련
    private func addSubViews() {
        for gender in [manButton, girlButton, otherButton] {
            genderButtons.append(gender)
        }
        for stackViewItem in genderButtons {
            stackView.addArrangedSubview(stackViewItem)
        }
        for viewItem in [progressView, notifyLabel, subNotifyLabel, stackView, nextButton] {
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
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(subNotifyLabel.snp.bottom).offset(10)
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
            make.height.equalTo(200)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.bottom.equalTo(safeArea).offset(-30)
            make.height.equalTo(50)
        }
        
    }
}
