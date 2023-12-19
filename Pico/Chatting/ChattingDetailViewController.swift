//
//  ChattingViewController.swift
//  Pico
//
//  Created by 양성혜 on 2023/12/16.
//

import UIKit

final class ChattingDetailViewController: UIViewController {
    
    var opponentUid: String?
    
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
        return textField
    }()
    
    private let sendButton: UIButton = {
        let button = CommonButton(type: .custom)
        button.setTitle("보내기", for: .normal)
        button.backgroundColor = .picoGray
        return button
    }()
    
    override func viewDidLoad() {
       super.viewDidLoad()
        addViews()
        makeConstraints()
    }
    
    func addViews() {
        sendStack.addArrangedSubview([chatTextField,sendButton])
        view.addSubview([chattingView,sendStack])
    }
    
    func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        sendStack.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(safeArea)
            make.height.equalTo(70)
        }
        
        chattingView.snp.makeConstraints { make in
            make.top.trailing.leading.equalTo(safeArea)
            make.bottom.equalTo(sendStack.snp.top)
        }
    }
}
