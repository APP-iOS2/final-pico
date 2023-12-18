//
//  InputPopupViewController.swift
//  Pico
//
//  Created by 신희권 on 12/15/23.
//

import UIKit

final class InputCustomPopupViewController: UIViewController {
    
    var titleText: String = "titletitletitletitletitletitletitle"
    var messageText: String = ""
    var cancelButtonText: String = "Cancel"
    var confirmButtonText: String = "OK"
    var alertType: AlertType = .onlyConfirm
    var confirmAction: ((String) -> Void)?
    var cancelAction: (() -> Void)?
    
    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        return view
    }()
    
    private let alertView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 5, height: 5)
        view.layer.shadowRadius = 2
        view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: view.layer.cornerRadius).cgPath
        view.layer.masksToBounds = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .picoSubTitleFont
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .picoDescriptionFont
        label.textColor = .gray
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.backgroundColor = .white
        button.setTitleColor(.picoBlue, for: .normal)
        button.layer.borderColor = UIColor.picoBlue.cgColor
        button.layer.borderWidth = 1
        button.tintColor = .clear
        return button
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.backgroundColor = .picoBlue
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .clear
        return button
    }()
    
    private let reasonTextView: UITextView = {
        let textView = UITextView()
        textView.clipsToBounds = true
        textView.layer.cornerRadius = 10
        textView.layer.borderColor = UIColor.picoBlue.cgColor
        textView.layer.borderWidth = 1
        textView.textContainer.maximumNumberOfLines = 5
        return textView
    }()
    
    private lazy var buttonsView: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        addViews()
        makeConstraints()
        configButtons()
    }
    
    private func configView() {
        view.backgroundColor = .clear
        titleLabel.text = titleText
        messageLabel.text = messageText
        confirmButton.setTitle(confirmButtonText, for: .normal)
        cancelButton.setTitle(cancelButtonText, for: .normal)
        reasonTextView.delegate = self
    }
    
    private func configButtons() {
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    private func getReasonText() -> String {
        return reasonTextView.text
    }
    
    @objc func confirmButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true) { [weak self] in
            self?.confirmAction?(self?.getReasonText() ?? "기타 사유")
        }
    }
    
    @objc func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true) { [weak self] in
            self?.cancelAction?()
        }
    }
    
    private func addViews() {
        view.addSubview([dimView, alertView, reasonTextView])
        buttonsView.addSubview([cancelButton, confirmButton])
        alertView.addSubview([titleLabel, messageLabel, buttonsView])
    }
    
    private func makeConstraints() {
        let safeArea = self.view.safeAreaLayoutGuide
        
        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        alertView.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(safeArea)
            make.height.lessThanOrEqualTo(safeArea).multipliedBy(0.4)
            if UIDevice.current.model.contains("iPhone") {
                make.width.equalTo(safeArea).multipliedBy(0.7)
            } else if UIDevice.current.model.contains("iPad") {
                make.width.equalTo(300)
            }
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(titleLabel.font.pointSize)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualTo(buttonsView.snp.top).offset(-20)
            make.width.equalTo(titleLabel)
        }
        
        reasonTextView.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(titleLabel)
            make.height.equalTo(100)
        }
        
        buttonsView.snp.makeConstraints { make in
            make.top.equalTo(reasonTextView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(80)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(35)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(35)
        }
    }
}

extension InputCustomPopupViewController: UITextViewDelegate {
//    func textViewDidEndEditing(_ textView: UITextView) {
//        if reasonTextView.text.isEmpty {
//            reasonTextView.text = "플레이스홀더입니다"
//            reasonTextView.textColor = UIColor.lightGray
//        }
//    }
//    
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        if reasonTextView.textColor == UIColor.lightGray {
//            reasonTextView.text = nil
//            reasonTextView.textColor = UIColor.black
//        }
//    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count < 150
    }
}
