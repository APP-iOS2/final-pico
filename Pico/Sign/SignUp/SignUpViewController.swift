//
//  SignUpViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import SwiftUI

final class SignUpViewController: UIViewController {
    
    private var stss: [String] = ["", "", "", ""]
    
    private let picoLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let progressView: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = .picoBetaBlue
        view.progressTintColor = .picoBlue
        view.progress = 0.1
        view.layer.cornerRadius = 5
        return view
    }()
    
    private let notifyLabel: UILabel = {
        let label = UILabel()
        label.text = "성격유형을 선택하세요."
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.picoTitleFont
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        return stackView
    }()
    
    private let mbtiFirstButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 50, weight: .bold)
        button.setTitleColor(.picoFontBlack, for: .normal)
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 10
        button.tag = 1
        button.clipsToBounds = true
        return button
    }()
    
    private let mbtiSecondButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 50, weight: .bold)
        button.setTitleColor(.picoFontBlack, for: .normal)
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 10
        button.tag = 2
        button.clipsToBounds = true
        return button
    }()
    
    private let mbtiThirdButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 50, weight: .bold)
        button.setTitleColor(.picoFontBlack, for: .normal)
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 10
        button.tag = 3
        button.clipsToBounds = true
        return button
    }()
    
    private let mbtiFourthButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 50, weight: .bold)
        button.setTitleColor(.picoFontBlack, for: .normal)
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 10
        button.tag = 4
        button.clipsToBounds = true
        return button
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
        configButton()
    }
    
    private func configButton() {
        mbtiFirstButton.addTarget(self, action: #selector(tappedMbtiButton), for: .touchUpInside)
        mbtiSecondButton.addTarget(self, action: #selector(tappedMbtiButton), for: .touchUpInside)
        mbtiThirdButton.addTarget(self, action: #selector(tappedMbtiButton), for: .touchUpInside)
        mbtiFourthButton.addTarget(self, action: #selector(tappedMbtiButton), for: .touchUpInside)
    }
    
    @objc private func tappedMbtiButton(_ sender: UIButton) {
        
        let modalVC = MbtiModalViewController()
        
        if let sheet = modalVC.sheetPresentationController {
            sheet.detents = [.medium(), .medium()]
        }
        
        switch sender.tag {
        case 1:
            modalVC.firstWord = "E"
            modalVC.secondWord = "I"
            modalVC.num = 1
            modalVC.delegate = self
            present(modalVC, animated: true)
            
        case 2:
            modalVC.firstWord = "S"
            modalVC.secondWord = "N"
            modalVC.num = 2
            modalVC.delegate = self
            present(modalVC, animated: true)
            
        case 3:
            modalVC.firstWord = "T"
            modalVC.secondWord = "F"
            modalVC.num = 3
            modalVC.delegate = self
            present(modalVC, animated: true)
            
        case 4:
            modalVC.firstWord = "J"
            modalVC.secondWord = "P"
            modalVC.num = 4
            modalVC.delegate = self
            present(modalVC, animated: true)
                
        default: break
        }
    }
    
    private func addSubViews() {
        for stackViewItem in [mbtiFirstButton, mbtiSecondButton, mbtiThirdButton, mbtiFourthButton] {
            stackView.addArrangedSubview(stackViewItem)
        }
        for viewItem in [picoLogoImageView, progressView, notifyLabel, stackView, nextButton] {
            view.addSubview(viewItem)
        }
    }
    
    private func makeConstraints() {
        let safeArea = self.view.safeAreaLayoutGuide
        picoLogoImageView.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(-10)
            make.leading.equalTo(10)
            make.height.equalTo(100)
        }
        progressView.snp.makeConstraints { make in
            make.top.equalTo(picoLogoImageView.snp.bottom).offset(-10)
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
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(notifyLabel.snp.bottom).offset(10)
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
            make.height.equalTo(75)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.bottom.equalTo(safeArea).offset(-30)
            make.height.equalTo(50)
        }
    }
}

extension SignUpViewController: SignViewControllerDelegate {
    func choiceMbti(mbti: String, num: Int) {
        switch num {
        case 1:
            stss[num - 1] = mbti
            mbtiFirstButton.setTitle(mbti, for: .normal)
        case 2:
            stss[num - 1] = mbti
            mbtiSecondButton.setTitle(mbti, for: .normal)
        case 3:
            stss[num - 1] = mbti
            mbtiThirdButton.setTitle(mbti, for: .normal)
        case 4:
            stss[num - 1] = mbti
            mbtiFourthButton.setTitle(mbti, for: .normal)
        default:
            return
        }
    }
    
}
