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
    
    var firstTitleText: String?
    var firstSubTitleText: String?
    var secondTitleText: String?
    var secondSubTitleText: String?
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
    
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        return stackView
    }()
    
    private lazy var leftUiView: UIView = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedUiView))
        let view = UIView()
        view.addGestureRecognizer(tapGesture)
        view.backgroundColor = .picoAlphaWhite
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.tag = 1
        return view
    }()
    
    private lazy var rightUiView: UIView = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedUiView))
        let view = UIView()
        view.addGestureRecognizer(tapGesture)
        view.backgroundColor = .picoAlphaWhite
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.tag = 2
        return view
    }()
    
    private let leftTitleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 50, weight: .regular)
        label.tag = 1
        return label
    }()
    
    private let leftSubTitleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .gray
        label.tag = 1
        return label
    }()
    
    private let rightTitleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 50, weight: .regular)
        label.tag = 2
        return label
    }()
    
    private let rightSubTitleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .gray
        label.tag = 2
        return label
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addSubViews()
        makeConstraints()
        configMbtiButton()
    }
    
    // MARK: - config
    
    private func configMbtiButton() {
        
        leftTitleLabel.text = firstTitleText
        leftSubTitleLabel.text = firstSubTitleText
        rightTitleLabel.text = secondTitleText
        rightSubTitleLabel.text = secondSubTitleText
    }
    
    @objc private func tappedUiView(_ sender: UITapGestureRecognizer) {
        guard let leftTitle = leftTitleLabel.text else { return }
        guard let rightTitle = rightTitleLabel.text else { return }
        
        guard let number = num else { return }
        
        if sender.view?.tag == 1 {
            sender.view?.backgroundColor = .picoBetaBlue
            self.delegate?.choiceMbti(mbti: leftTitle, num: number)
        } else {
            sender.view?.backgroundColor = .picoBetaBlue
            self.delegate?.choiceMbti(mbti: rightTitle, num: number)
        }
        slowDownModal()
    }
    
    // MARK: - UI 관련
    private func slowDownModal() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.frame.origin.y += self.view.frame.size.height
        }, completion: { _ in
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    private func addSubViews() {
        view.addSubview(notifyLabel)
        view.addSubview(buttonsStackView)
        for stackViewItem in [leftUiView, rightUiView] {
            buttonsStackView.addArrangedSubview(stackViewItem)
        }
        leftUiView.addSubview(leftTitleLabel)
        leftUiView.addSubview(leftSubTitleLabel)
        rightUiView.addSubview(rightTitleLabel)
        rightUiView.addSubview(rightSubTitleLabel)
        
    }
    
    private func makeConstraints() {
        let safeArea = self.view.safeAreaLayoutGuide
        
        notifyLabel.snp.makeConstraints { make in
            make.top.equalTo(safeArea.snp.top).offset(20)
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
        }
        
        buttonsStackView.snp.makeConstraints { make in
            make.top.equalTo(notifyLabel.snp.bottom).offset(20)
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.height.equalTo(150)
        }
        
        leftTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(leftUiView).offset(-15)
            make.centerX.equalTo(leftUiView)
        }
        
        leftSubTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(leftTitleLabel.snp.bottom).offset(5)
            make.centerX.equalTo(leftUiView)
        }
        
        rightTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(rightUiView).offset(-15)
            make.centerX.equalTo(rightUiView)
        }
        
        rightSubTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(rightTitleLabel.snp.bottom).offset(5)
            make.centerX.equalTo(rightUiView)
        }
    }
}
