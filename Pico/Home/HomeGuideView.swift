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
        view.backgroundColor = .white
        return view
    }()
    
    private let guideTabImageView: UIImageView = {
        let view = UIImageView()
        if let image = UIImage(named: "guideTab") {
            view.image = image
            view.contentMode = .scaleAspectFit
            view.layer.opacity = 0.9
            view.frame.size = image.size // 이미지 크기에 맞게 프레임 설정
        }
        return view
    }()
    
    private let guideGestureImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "guideGesture")
        view.contentMode = .scaleAspectFit
        view.layer.opacity = 0.9
        return view
    }()
    
    private let guideTitle: UILabel = {
        let label = UILabel()
        label.text = "PICO Home Guide"
        label.textColor = .picoBlue
        label.font = .picoTitleFont
        label.textAlignment = .center
        return label
    }()
    
    private let guideSubLabel: UILabel = {
        let label = UILabel()
        let text = """
                    사진을 탭하여 상대의 사진을 확인 할 수 있습니다.
                    화면을 드래그해서 빠르게 친구를 찾아보세요.
                    뒤로가기 버튼으로 지나간 친구를 다시 불러옵니다.
                    마이페이지 프로필을 완성해서 매칭 확률을 높여보세요!
                    """
        let attributedText = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        attributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.length))
        
        label.attributedText = attributedText
        label.textColor = .gray
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .picoContentFont
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setTitle("닫기", for: .normal)
        button.titleLabel?.font = .picoButtonFont
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 20
        return button
    }()
    private let closeAgainButton: UIButton = {
        let button = UIButton()
        button.setTitle("다시보지 않기", for: .normal)
        button.titleLabel?.font = .picoButtonFont
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .picoBlue
        button.layer.cornerRadius = 20
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
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
        backgroundView.addSubview([guideTitle, guideTabImageView, guideGestureImageView, guideSubLabel, closeButton, closeAgainButton])
    }
    
    private func makeConstraints() {
        let horizontalSpacing = 20
        let verticalSpacing = 80
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        guideTabImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(verticalSpacing)
            make.leading.equalToSuperview().offset(horizontalSpacing)
            make.trailing.equalTo(safeAreaLayoutGuide.snp.centerX).offset(-horizontalSpacing / 2)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.centerY).offset(verticalSpacing / 2)
        }
        
        guideGestureImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(verticalSpacing)
            make.leading.equalTo(safeAreaLayoutGuide.snp.centerX).offset(horizontalSpacing / 2)
            make.trailing.equalToSuperview().offset(-horizontalSpacing)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.centerY).offset(verticalSpacing / 2)
        }
        
        guideTitle.snp.makeConstraints { make in
            make.top.equalTo(guideTabImageView.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        
        guideSubLabel.snp.makeConstraints { make in
            make.top.equalTo(guideTitle.snp.bottom)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(100)
        }
        
        closeAgainButton.snp.makeConstraints { make in
            make.centerX.equalTo(Screen.width * 0.3)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-30)
            make.width.equalTo(140)
            make.height.equalTo(40)
        }
        
        closeButton.snp.makeConstraints { make in
            make.centerX.equalTo(Screen.width * 0.7)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-30)
            make.width.equalTo(140)
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
