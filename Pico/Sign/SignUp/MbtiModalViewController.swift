//
//  MbtiModalViewController.swift
//  Pico
//
//  Created by LJh on 2023/09/26.
//

import UIKit

protocol SignViewControllerDelegate: AnyObject {
    func getUserMbti(mbti: String, num: Int)
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
        label.font = UIFont.picoSubTitleFont
        return label
    }()
    
    private let buttonHorizontalStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        return stackView
    }()
    
    private let leftUiView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        view.addShadow(offset: CGSize(width: 4, height: 4), opacity: 0.2, radius: 5)
        view.tag = 1
        return view
    }()
    
    private let rightUiView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        view.addShadow(offset: CGSize(width: 4, height: 4), opacity: 0.2, radius: 3)
        view.tag = 2
        return view
    }()
    
    private let leftTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .picoMBTISelectedLabelFont
        label.textColor = .picoFontBlack
        label.tag = 1
        return label
    }()
    
    private let leftSubTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .picoMBTISelectedSubLabelFont
        label.textColor = .picoFontBlack
        label.tag = 1
        return label
    }()
    
    private let rightTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .picoMBTISelectedLabelFont
        label.textColor = .picoFontBlack
        label.tag = 2
        return label
    }()
    
    private let rightSubTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .picoMBTISelectedSubLabelFont
        label.textColor = .picoFontBlack
        label.tag = 2
        return label
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.configBackgroundColor(color: .systemBackground)        
        addSubViews()
        makeConstraints()
        configMbtiButton()
        configButton()
    }
}
// MARK: - Config
extension MbtiModalViewController {
    private func configMbtiButton() {
        leftTitleLabel.text = firstTitleText
        leftSubTitleLabel.text = firstSubTitleText
        rightTitleLabel.text = secondTitleText
        rightSubTitleLabel.text = secondSubTitleText
    }
    
    private func configButton() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedUiView))
        leftUiView.addGestureRecognizer(tapGesture)
        rightUiView.addGestureRecognizer(tapGesture)
    }
    // MARK: - @objc
    @objc private func tappedUiView(_ sender: UITapGestureRecognizer) {
        guard let leftTitle = leftTitleLabel.text else { return }
        guard let rightTitle = rightTitleLabel.text else { return }
        
        guard let number = num else { return }
        
        if sender.view?.tag == 1 {
            sender.view?.backgroundColor = .picoBetaBlue
            
            sender.view?.addShadow(offset: CGSize(width: 1, height: 2), color: .picoBetaBlue, opacity: 0.8)
            self.delegate?.getUserMbti(mbti: leftTitle, num: number)
        } else {
            sender.view?.backgroundColor = .picoBetaBlue
            sender.view?.addShadow(offset: CGSize(width: 1, height: 2), color: .picoBetaBlue, opacity: 0.8)
            self.delegate?.getUserMbti(mbti: rightTitle, num: number)
        }
        slowDownModal()
    }
}
// MARK: - UI 관련
extension MbtiModalViewController {
    
    private func slowDownModal() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.frame.origin.y += self.view.frame.size.height
        }, completion: { _ in
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    private func addSubViews() {
        view.addSubview(notifyLabel)
        view.addSubview(buttonHorizontalStack)
        for stackViewItem in [leftUiView, rightUiView] {
            buttonHorizontalStack.addArrangedSubview(stackViewItem)
        }
        leftUiView.addSubview(leftTitleLabel)
        leftUiView.addSubview(leftSubTitleLabel)
        rightUiView.addSubview(rightTitleLabel)
        rightUiView.addSubview(rightSubTitleLabel)
    }
    
    private func makeConstraints() {
        let safeArea = self.view.safeAreaLayoutGuide
        
        notifyLabel.snp.makeConstraints { make in
            make.top.equalTo(safeArea.snp.top).offset(30)
            make.leading.equalTo(SignView.padding)
            make.trailing.equalTo(-SignView.padding)
        }
        
        buttonHorizontalStack.snp.makeConstraints { make in
            make.top.equalTo(notifyLabel.snp.bottom).offset(30)
            make.leading.equalTo(SignView.contentPadding)
            make.trailing.equalTo(-SignView.contentPadding)
            make.height.equalTo(150)
        }
        
        leftTitleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(leftUiView)
            make.centerY.equalTo(leftUiView).offset(-SignView.padding)
        }
        
        leftSubTitleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(leftUiView)
            make.top.equalTo(leftTitleLabel.snp.bottom).offset(5)
        }
        
        rightTitleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(rightUiView)
            make.centerY.equalTo(rightUiView).offset(-SignView.padding)
        }
        
        rightSubTitleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(rightUiView)
            make.top.equalTo(rightTitleLabel.snp.bottom).offset(5)
        }
    }
}
