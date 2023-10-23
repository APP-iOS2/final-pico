//
//  TermsOfServiceModalViewController.swift
//  Pico
//
//  Created by LJh on 10/21/23.
//

import UIKit

final class TermsOfServiceModalViewController: UIViewController {
    private let tag: Int
    private let termsOfServiceTexts: [String] = TermsOfServiceText.termsOfServiceTexts
    private let termTitle = TermsOfServiceText.termsTitle
    init(tag: Int) {
        self.tag = tag
        super.init(nibName: nil, bundle: nil)
        setupUI()
        titleLabel.text = termTitle[tag]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.text = termsOfServiceTexts[tag]
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .picoFontBlack
        textView.backgroundColor = .white
        textView.showsVerticalScrollIndicator = false
        return textView
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        if let symbolImage = UIImage(systemName: "xmark.circle")?.withRenderingMode(.alwaysTemplate) {
            button.setImage(symbolImage, for: .normal)
        }
        button.tintColor = .picoFontGray
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        button.setPreferredSymbolConfiguration(symbolConfiguration, forImageIn: .normal)
        button.addTarget(self, action: #selector(tappedCloseButton), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "서비스 이용약관"
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textColor = .picoFontBlack
        return label
    }()
    
    @objc private func tappedCloseButton() {
        dismiss(animated: true, completion: nil)
    }
}

extension TermsOfServiceModalViewController {
    private func setupUI() {
        let safeArea = view.safeAreaLayoutGuide
        view.configBackgroundColor(color: .systemBackground) 
        view.addSubview(closeButton)
        view.addSubview(textView)
        view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(30)
            make.centerX.equalTo(safeArea)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel)
            make.trailing.equalTo(safeArea).offset(-SignView.padding)
        }

        textView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(SignView.padding)
            make.leading.equalTo(safeArea).offset(SignView.padding)
            make.trailing.equalTo(safeArea).offset(-SignView.padding)
            make.bottom.equalTo(safeArea).offset(-SignView.padding)
        }
    }
}
