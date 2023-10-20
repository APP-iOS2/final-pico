//
//  HomeGuideView.swift
//  Pico
//
//  Created by 임대진 on 10/19/23.
//

import UIKit
import SnapKit

final class HomeGuideView: UIView {
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.9)
        return view
    }()
    
    private let pickBackButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 35, weight: .regular)
        let image = UIImage(systemName: "arrow.uturn.backward", withConfiguration: imageConfig)
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .lightGray.withAlphaComponent(0.5)
        button.frame = CGRect(x: 0, y: 0, width: 65, height: 65)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.layer.opacity = 0.9
        return button
    }()
    
    private let guideTabImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "guideTab")
        view.contentMode = .scaleAspectFill
        view.layer.opacity = 0.9
        return view
    }()
    
    private let guideGestureImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "guideGesture")
        view.contentMode = .scaleAspectFill
        view.layer.opacity = 0.9
        return view
    }()
    
    private let backInfoIcon: UIImageView = {
        let view = UIImageView()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        view.image = UIImage(systemName: "arrow.turn.left.down", withConfiguration: imageConfig)
        view.tintColor = .picoAlphaWhite
        return view
    }()
    
    private let guideTitle: UILabel = {
        let label = UILabel()
        label.text = "PICO Home Guide"
        label.textColor = .white.withAlphaComponent(0.9)
        label.font = .picoTitleFont
        label.textAlignment = .center
        return label
    }()
    
    private let guideTabLabel: UILabel = {
        let label = UILabel()
        label.text = "이미지를 넘깁니다."
        label.textColor = .white.withAlphaComponent(0.9)
        label.font = .picoSubTitleFont
        label.textAlignment = .center
        return label
    }()
    
    private let guideGestureLabel: UILabel = {
        let label = UILabel()
        label.text = "유저를 평가합니다."
        label.textColor = .white.withAlphaComponent(0.9)
        label.font = .picoSubTitleFont
        label.textAlignment = .center
        return label
    }()
    
    private let backInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "이전 평가로 돌아갑니다."
        label.textColor = .white.withAlphaComponent(0.9)
        label.font = .picoSubTitleFont
        label.textAlignment = .center
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setTitle("닫기", for: .normal)
        button.titleLabel?.font = .picoSubTitleFont
        button.tintColor = .picoAlphaWhite
        button.layer.cornerRadius = 20
        return button
    }()
    private let closeAgainButton: UIButton = {
        let button = UIButton()
        button.setTitle("다시보지 않기", for: .normal)
        button.titleLabel?.font = .picoSubTitleFont
        button.tintColor = .picoAlphaWhite
        button.layer.cornerRadius = 20
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        
        addSubview()
        makeConstraints()
        configButton()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubview() {
        addSubview(backgroundView)
        backgroundView.addSubview([guideTitle, guideTabImageView, guideGestureImageView, guideTabLabel, guideGestureLabel, backInfoIcon, backInfoLabel, pickBackButton, closeButton, closeAgainButton])
    }
    
    private func makeConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        guideTitle.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        
        guideTabImageView.snp.makeConstraints { make in
            if UIDevice.current.model.contains("iPhone") {
                make.centerY.equalTo(Screen.height * 0.35)
            } else if UIDevice.current.model.contains("iPad") {
                make.centerY.equalTo(Screen.height * 0.4)
            }
            make.centerX.equalTo(Screen.width * 0.25)
            make.size.equalTo(Screen.width * 0.35)
        }
        
        guideGestureImageView.snp.makeConstraints { make in
            if UIDevice.current.model.contains("iPhone") {
                make.centerY.equalTo(Screen.height * 0.35)
            } else if UIDevice.current.model.contains("iPad") {
                make.centerY.equalTo(Screen.height * 0.4)
            }
            make.centerX.equalTo(Screen.width * 0.75)
            make.size.equalTo(Screen.width * 0.35)
        }
        
        guideTabLabel.snp.makeConstraints { make in
            make.top.equalTo(guideTabImageView.snp.bottom).offset(100)
            make.centerX.equalTo(guideTabImageView)
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        
        guideGestureLabel.snp.makeConstraints { make in
            make.top.equalTo(guideTabImageView.snp.bottom).offset(100)
            make.centerX.equalTo(guideGestureImageView)
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        
        backInfoIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(40)
            make.centerY.equalTo(Screen.height * 0.75)
        }
        
        backInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(backInfoIcon.snp.top).offset(-15)
            make.leading.equalTo(backInfoIcon.snp.trailing).offset(-5)
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        
        pickBackButton.snp.makeConstraints { make in
            make.top.equalTo(backInfoIcon.snp.bottom).offset(10)
            make.centerX.equalTo(backInfoIcon)
            make.width.equalTo(65)
            make.height.equalTo(65)
        }
        
        closeButton.snp.makeConstraints { make in
            make.leading.equalTo(safeAreaLayoutGuide.snp.centerX).offset(10)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-10)
            make.width.equalTo(120)
            make.height.equalTo(40)
        }
        
        closeAgainButton.snp.makeConstraints { make in
            make.trailing.equalTo(safeAreaLayoutGuide.snp.centerX).offset(-10)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-10)
            make.width.equalTo(120)
            make.height.equalTo(40)
        }
    }
    
    private func configButton() {
        closeButton.addTarget(self, action: #selector(tappedCloseButton), for: .touchUpInside)
        closeAgainButton.addTarget(self, action: #selector(tappedCloseAgainButton), for: .touchUpInside)
    }
    
    @objc func tappedCloseButton() {
        self.removeFromSuperview()
    }
    
    @objc func tappedCloseAgainButton() {
        self.removeFromSuperview()
        UserDefaults.standard.setValue(true, forKey: UserDefaultsManager.Key.dontWatchAgain.rawValue)
    }
}
