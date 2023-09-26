//
//  MbtiModalViewController.swift
//  Pico
//
//  Created by LJh on 2023/09/26.
//

import UIKit

protocol SignViewControllerDelegate: AnyObject {
    func choiceMbti(mbti: String, num: Int)
}

final class MbtiModalViewController: UIViewController {
    
    var firstWord: String?
    var secondWord: String?
    var num: Int?
    weak var delegate: SignViewControllerDelegate?
    
    private let notifyLabel: UILabel = {
        let label = UILabel()
        label.text = "당신은 어떤사람인가요?"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.picoTitleFont
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 50
        return stackView
    }()
    
    private let mbtiFirstButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 50, weight: .bold)
        button.setTitleColor(.picoFontBlack, for: .normal)
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 10
        button.tag = 0
        button.clipsToBounds = true
        return button
    }()
    
    private let mbtiSecondButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 50, weight: .bold)
        button.setTitleColor(.picoFontBlack, for: .normal)
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 10
        button.tag = 1
        button.clipsToBounds = true
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
        guard let firstWord else { return }
        guard let secondWord else { return }
        mbtiFirstButton.setTitle(firstWord, for: .normal)
        mbtiSecondButton.setTitle(secondWord, for: .normal)
        
        mbtiFirstButton.addTarget(self, action: #selector(tappedMbtiButton), for: .touchUpInside)
        mbtiSecondButton.addTarget(self, action: #selector(tappedMbtiButton), for: .touchUpInside)
    }
    
    @objc func tappedMbtiButton(_ sender: UIButton) {
        tappedButtonAnimation(sender)
        guard let text = sender.titleLabel?.text else { return }
        guard let number = num else { return }
        switch sender.tag {
        case 0:
            mbtiFirstButton.backgroundColor = .picoBetaBlue
        case 1:
            mbtiSecondButton.backgroundColor = .picoBetaBlue
        default:
            break
        }
        self.delegate?.choiceMbti(mbti: text, num: number)
        UIView.animate(withDuration: 0.7, animations: {
            self.view.frame.origin.y += self.view.frame.size.height
        }, completion: { _ in
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    // MARK: - UI 관련
    private func addSubViews() {
        for stackViewItem in [mbtiFirstButton, mbtiSecondButton] {
            stackView.addArrangedSubview(stackViewItem)
        }
        
        for viewItem in [notifyLabel, stackView] {
            view.addSubview(viewItem)
        }
    }
    
    private func makeConstraints() {
        let safeArea = self.view.safeAreaLayoutGuide
        
        notifyLabel.snp.makeConstraints { make in
            make.top.equalTo(safeArea.snp.top).offset(20)
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
            make.height.equalTo(50)
        }
        
        stackView.snp.makeConstraints { make in
            make.centerY.equalTo(safeArea)
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
            make.height.equalTo(130)
        }
    }
}
