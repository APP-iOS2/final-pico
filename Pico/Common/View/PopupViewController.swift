//
//  CustomPopupViewController.swift
//  CustomUIComponents
//
//  Created by 방유빈 on 2023/09/22.
//

import UIKit

enum AlertType {
    case onlyConfirm /// 확인 버튼만 있는 Alert Type
    case canCancel /// 확인 + 취소 버튼 있는 Alert Type
}

class CustomPopupViewController: UIViewController {
    
    var titleText: String = "titletitletitletitletitletitletitle"
    var messageText: String = ""
    var cancelButtonText: String = "Cancel"
    var confirmButtonText: String = "OK"
    var alertType: AlertType = .onlyConfirm
    var confirmAction: (() -> Void)?
    var cancelAction: (() -> Void)?

    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        return view
    }()
    
    private let alertView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
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
        label.font = .picoTitleFont
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.clipsToBounds = true
        button.layer.cornerRadius = 15
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
        button.layer.cornerRadius = 15
        button.backgroundColor = .picoBlue
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .clear
        return button
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
    }
    
    private func configButtons() {
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    @objc func confirmButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true) { [weak self] in
            self?.confirmAction?()
        }
    }
    
    @objc func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true) { [weak self] in
            self?.cancelAction?()
        }
    }
    
    private func addViews() {
        view.addSubview([dimView, alertView])
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
            make.width.equalTo(safeArea).multipliedBy(0.8)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(titleLabel.font.pointSize)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualTo(buttonsView.snp.top).offset(-20)
            make.width.equalTo(titleLabel)
        }
        
        buttonsView.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
            make.width.equalTo(titleLabel)
            make.height.greaterThanOrEqualTo(80)
        }
        switch alertType {
        case .onlyConfirm:
            buttonsView.snp.updateConstraints { make in
                make.height.equalTo(40)
            }
            confirmButton.snp.makeConstraints { make in
                make.top.leading.trailing.bottom.equalToSuperview()
            }
        case .canCancel:
            confirmButton.snp.makeConstraints { make in
                make.top.leading.trailing.equalToSuperview()
            }
            cancelButton.snp.makeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
            }
        }
    }
    
}
