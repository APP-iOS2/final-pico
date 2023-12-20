//
//  ChattingViewController.swift
//  Pico
//
//  Created by 양성혜 on 2023/12/16.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ChattingDetailViewController: UIViewController {
    
    var opponentId: String = ""
    var opponentName: String = ""
    var roomId: String = ""
    
    private let viewModel = ChattingViewModel()
    private let disposeBag = DisposeBag()
    
    private let chattingView: UIView = {
        let uiView = UIView()
        return uiView
    }()
    private let sendStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        return stackView
    }()
    
    private let chatTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "채팅을 입력해주세요"
        textField.font = UIFont.picoDescriptionFont
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.picoFontGray.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 12.0, height: 0.0))
        textField.leftViewMode = .always
        return textField
    }()
    
    private let sendButton: UIButton = {
        let button = CommonButton(type: .custom)
        button.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        button.backgroundColor = .white
        button.tintColor = .picoBlue
        return button
    }()
    
    override func viewDidLoad() {
       super.viewDidLoad()
        addViews()
        makeConstraints()
        configViewController()
    }
    
    private func addViews() {
        sendStack.addArrangedSubview([chatTextField,sendButton])
        view.addSubview([chattingView,sendStack])
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        sendButton.snp.makeConstraints { make in
            make.width.equalTo(50)
        }
        
        sendStack.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(10)
            make.trailing.bottom.equalTo(safeArea).offset(-10)
            make.height.equalTo(40)
        }
        
        chattingView.snp.makeConstraints { make in
            make.top.trailing.leading.equalTo(safeArea)
            make.bottom.equalTo(sendStack.snp.top)
        }
    }
    
    private func configViewController() {
        view.configBackgroundColor()
        navigationItem.title = opponentName
        tabBarController?.tabBar.isHidden = true
    }
    
    private func configSendButton() {
        sendButton.rx.tap
            .bind { [weak self] _ in
                guard let self = self  else { return }
                self.sendButton.tappedAnimation()
                if let text = self.chatTextField.text {
                    // sender: 로그인한 사람, recevie 받는 사람
                    self.viewModel.saveChattingData(receiveUserId: opponentId, message: text, type: .chatting)
                }
            }
            .disposed(by: disposeBag)
    }
}
