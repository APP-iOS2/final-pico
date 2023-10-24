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
        button.titleLabel?.font = .picoContentBoldFont
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
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private lazy var tableViewController = [MailSendTableListController(), MailReceiveTableListController(viewController: self)]
    
    private let contentsView: UIView = UIView()
    
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
        view.addSubview([buttonStack, contentsView])
        contentsView.addSubview([pageViewController.view])
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(10)
            make.leading.equalTo(safeArea.snp.leading).offset(10)
        }
        
        sendButton.snp.makeConstraints { make in
            make.width.equalTo(70)
        }
        
        receiveButton.snp.makeConstraints { make in
            make.width.equalTo(70)
        }
        
        contentsView.snp.makeConstraints { make in
            make.top.equalTo(buttonStack.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalTo(safeArea)
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
                sender.titleLabel?.font = .picoContentBoldFont
                mailType = MailReceiveViewModel().toType(text: text)
                if mailType == .receive {
                    pageViewController.setViewControllers([tableViewController[1]], direction: .reverse, animated: true)
                } else {
                    pageViewController.setViewControllers([tableViewController[0]], direction: .forward, animated: true)
                }
            case false:
                button.backgroundColor = .picoGray
                button.titleLabel?.font = .picoDescriptionFont
            }
        }
    }
}
