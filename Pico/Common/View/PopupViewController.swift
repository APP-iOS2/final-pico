//
//  CustomPopupViewController.swift
//  CustomUIComponents
//
//  Created by 방유빈 on 2023/09/22.
//

import UIKit

protocol CustomAlertDelegate: AnyObject {
    func action()   // confirm button event
    func exit()     // cancel button event
}

enum AlertType {
    case onlyConfirm /// 확인 버튼만 있는 Alert Type
    case canCancel /// 확인 + 취소 버튼 있는 Alert Type
}

class CustomPopupViewController: UIViewController {
    
    var titleText: String = "titletitletitletitletitletitletitle"
    var messageText: String = "messagemessagemessagemessagemessagemessagemessagmessagemessagemessagemessagemessagemessagemessagmessagemessagemessagemessagemessagemessagemessagmessagemessagemessagemessagemessagemessagemessagmessagemessagemessagemessagemessagemessagemessagmessagemessagemessagemessagemessagemessagemessagmessagemessagemessagemessagemessagemessagemessagmessagemessagemessagemessagemessagemessagemessagmessagemessagemessagemessagemessagemessagemessagmessagemessagemessagemessagemessagemessagemessagmessagemessagemessagemessagemessagemessagemessagmessagemessagemessagemessagemessagemessagemessagmessagemessagemessagemessagemessagemessagemessag"
    var cancelButtonText: String = "Cancel"
    var confirmButtonText: String = "OK"
    var alertType: AlertType = .onlyConfirm
    
    var delegate: CustomAlertDelegate?
    
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
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = titleText
        label.font = .picoTitleFont
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.setTitle(cancelButtonText, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 15
        button.backgroundColor = .white
        button.setTitleColor(.picoBlue, for: .normal)
        button.layer.borderColor = UIColor.picoBlue.cgColor
        button.layer.borderWidth = 1
        button.tintColor = .clear
        return button
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.setTitle(confirmButtonText, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 15
        button.backgroundColor = .picoBlue
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .clear
        return button
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = messageText
        label.textAlignment = .center
        label.font = .picoDescriptionFont
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var buttonsView: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        addViews()
        makeConstraints()
        configButtons()
        // Do any additional setup after loading the view.
    }
    
    private func configView() {
        view.backgroundColor = .clear
    }
    
    private func configButtons() {
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    @objc func confirmButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.action()
        }
    }
    
    @objc func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.exit()
        }
    }
    
    private func addViews() {
        [dimView, alertView].forEach {
            view.addSubview($0)
        }
        
        [cancelButton, confirmButton].forEach {
            buttonsView.addSubview($0)
        }
        
        [titleLabel, messageLabel, buttonsView].forEach {
            alertView.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        let safeArea = self.view.safeAreaLayoutGuide
        
        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        alertView.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(safeArea)
            make.height.equalTo(safeArea).multipliedBy(0.4)
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
            make.width.equalTo(titleLabel)
        }
        
        buttonsView.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
            make.width.equalTo(titleLabel)
            make.height.equalTo(80)
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

extension CustomAlertDelegate where Self: UIViewController {
    func show(
        alertType: AlertType,
        titleText: String,
        messageText: String,
        cancelButtonText: String? = "취소",
        confirmButtonText: String
    ) {
        let customAlertViewController = CustomPopupViewController()
        
        customAlertViewController.delegate = self
        
        customAlertViewController.modalPresentationStyle = .overFullScreen
        customAlertViewController.modalTransitionStyle = .crossDissolve
        customAlertViewController.alertType = alertType
        customAlertViewController.titleText = titleText
        customAlertViewController.messageText = messageText
        customAlertViewController.cancelButtonText = cancelButtonText ?? "취소"
        customAlertViewController.confirmButtonText = confirmButtonText
        
        self.present(customAlertViewController, animated: true, completion: nil)
    }
}
/*
 extension ViewController: CustomAlertDelegate {
     func action() {
         // 확인 버튼 이벤트 처리
         print("확인")
     }
     
     func exit() {
         // 취소 버튼 이벤트 처리
         print("취소")
     }
 }
 사용할 뷰컨트롤러에서 델리게이트 구현 후
 @objc func touchUpCustomButton(_ sender: UIButton) {
     show(alertType: .canCancel, titleText: "축하드립니다~!", messageText: "축하드립니다. 무료 뽑기권에 당첨되셨습니다.\n이동하시겠습니까?", cancelButtonText: "취소", confirmButtonText: "이동")
 }
 
 @objc func touchUpMbtiButton(_ sender: UIButton) {
     show(alertType: .onlyConfirm, titleText: "ESTP", messageText: "축하드립니다. 당신은 ESTP입니다~", confirmButtonText: "이동")
 }
 이런식으로 사용
 -> 근데 이러면 같은 뷰컨트롤러에서 두가지 이상 알럿이 필요할 때 다른 액션 주는 방법이 이상해짐
 */
