//
//  MailViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import SnapKit

final class MailViewController: BaseViewController {
    
    private var mailTypeButtons: [UIButton] = []
    private var mailType: MailType = .receive
    
    private let mailText: UILabel = {
        let label = UILabel()
        label.text = "Mail"
        label.font = UIFont.picoTitleFont
        label.textColor = .picoFontBlack
        return label
    }()
    
    private let buttonStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        return stackView
    }()
    
    private let receiveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .picoAlphaBlue
        button.setTitle("받은 쪽지", for: .normal)
        button.titleLabel?.font = .picoDescriptionFont
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.setTitleColor(.white, for: .normal)
        button.isSelected = true
        return button
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .picoGray
        button.setTitle("보낸 쪽지", for: .normal)
        button.titleLabel?.font = .picoDescriptionFont
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.setTitleColor(.picoBetaBlue, for: .normal)
        return button
    }()
    
    private let tableViewController = [MailSendTableListController(), MailReceiveTableListController()]
    
    private let contentsView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var pageViewController: UIPageViewController = {
        let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageController.view.frame = contentsView.frame
        return pageController
    }()
    // MARK: - MailView +LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        makeConstraints()
        configMailTypeButtons()
        configPageView()
    }
    
    // MARK: - MailView +UI
    private func addViews() {
        [receiveButton, sendButton].forEach { item in
            mailTypeButtons.append(item)
        }
        buttonStack.addArrangedSubview([receiveButton, sendButton])
        view.addSubview([mailText, buttonStack, contentsView])
        contentsView.addSubview([pageViewController.view])
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        mailText.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(10)
            make.leading.equalTo(safeArea).offset(20)
            make.trailing.equalTo(safeArea).offset(-30)
        }
        
        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(mailText.snp.bottom).offset(10)
            make.leading.equalTo(safeArea.snp.leading).offset(20)
        }
        
        sendButton.snp.makeConstraints { make in
            make.width.equalTo(60)
        }
        
        receiveButton.snp.makeConstraints { make in
            make.width.equalTo(60)
        }
        
        contentsView.snp.makeConstraints { make in
            make.top.equalTo(buttonStack.snp.bottom).offset(10)
            make.leading.equalTo(safeArea).offset(10)
            make.trailing.bottom.equalTo(safeArea).offset(-10)
        }
    }
    // MARK: - config
    private func configMailTypeButtons() {
        sendButton.addTarget(self, action: #selector(tappedMailTypeButton), for: .touchUpInside)
        receiveButton.addTarget(self, action: #selector(tappedMailTypeButton), for: .touchUpInside)
    }
    
    private func configPageView() {
        pageViewController.setViewControllers([tableViewController[1]], direction: .reverse, animated: true)
    }
    // MARK: - objc
    @objc func tappedMailTypeButton(_ sender: UIButton) {
        for button in mailTypeButtons {
            button.isSelected = (button == sender)
            guard let text = sender.titleLabel?.text else { return }
            switch button.isSelected {
            case true:
                sender.backgroundColor = .picoAlphaBlue
                sender.setTitleColor(.white, for: .normal)
                mailType = MailReceiveModel().toType(text: text)
                if mailType == .receive {
                    pageViewController.setViewControllers([tableViewController[1]], direction: .reverse, animated: true)
                } else {
                    pageViewController.setViewControllers([tableViewController[0]], direction: .forward, animated: true)
                }
            case false:
                button.backgroundColor = .picoGray
                button.setTitleColor(.picoBetaBlue, for: .normal)
            }
        }
    }
}
