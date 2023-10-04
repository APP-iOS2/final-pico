//
//  WorldCupResultViewController.swift
//  Pico
//
//  Created by 오영석 on 2023/10/04.
//

import UIKit
import SnapKit

final class WorldCupResultViewController: UIViewController {
    
    var selectedItem: User?
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "gameBackground"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let worldCupTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 36)
        label.text = "이상형 월드컵"
        return label
    }()
    
    private let pickMeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.picoTitleFont
        label.text = "우승"
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.picoButtonFont
        label.textColor = .picoFontGray
        label.text = "농치기 아쉽다면?\n채팅을 신청해보세요!"
        label.numberOfLines = 0
        return label
    }()
    
    private let resultUserView: ResultUserView = {
        let view = ResultUserView()
        return view
    }()
    
    private let chatButton: CommonButton = {
        let button = CommonButton()
        button.setTitle("채팅 신청하기", for: .normal)
        return button
    }()
    
    private let guideLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.picoButtonFont
        label.text = "채팅 신청 비용 50츄 (50%)"
        label.textColor = .picoFontGray
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addViews()
        makeConstraints()
        configButton()
        configResultUserCell()
        addShadow()
    }
    
    private func addViews() {
        [backgroundImageView, worldCupTitleLabel, pickMeLabel, contentLabel, resultUserView, chatButton, guideLabel].forEach { item in
            view.addSubview(item)
        }
    }
    
    private func makeConstraints() {
        let padding: CGFloat = 20
        let half: CGFloat = 0.5
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        worldCupTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Screen.height / 6)
            make.centerX.equalToSuperview().offset(half)
        }
        
        pickMeLabel.snp.makeConstraints { make in
            make.top.equalTo(worldCupTitleLabel.snp.bottom).offset(padding * half)
            make.centerX.equalToSuperview().offset(half)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(pickMeLabel.snp.bottom).offset(padding * half)
            make.centerX.equalToSuperview().offset(half)
        }
        
        resultUserView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(padding * 2)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(200)
        }
        
        chatButton.snp.makeConstraints { make in
            make.top.equalTo(resultUserView.userNickname.snp.bottom).offset(padding * 2)
            make.centerX.equalToSuperview().offset(half)
            make.leading.equalToSuperview().offset(Screen.width / 4)
            make.trailing.equalToSuperview().offset(-Screen.width / 4)
            make.height.equalTo(Screen.width / 10)
        }
        
        guideLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-padding * 1.5)
        }
    }
    
    private func configButton() {
        chatButton.addTarget(WorldCupResultViewController.self, action: #selector(tappedChatButton), for: .touchUpInside)
    }
    
    private func configResultUserCell() {
        if let selectedItem = selectedItem {
            resultUserView.mbtiLabel.text = "\(selectedItem.mbti)"
            resultUserView.userNickname.text = "\(selectedItem.nickName)"
            
            if let imageURL = selectedItem.imageURLs.first, let url = URL(string: imageURL) {
                do {
                    let data = try Data(contentsOf: url)
                    resultUserView.userImage.image = UIImage(data: data)
                } catch {
                    print("이미지 로드 에러")
                }
            }
        }
    }
    
    private func addShadow(opacity: Float = 0.07, radius: CGFloat = 5.0) {
        resultUserView.layer.masksToBounds = false
        resultUserView.layer.shadowColor = UIColor.black.cgColor
        resultUserView.layer.shadowOffset = CGSize(width: 10, height: 10)
        resultUserView.layer.shadowOpacity = opacity
        resultUserView.layer.shadowRadius = radius
    }
    
    @objc func tappedChatButton() {
        // 채팅 신청하는 것으로 바뀌어야 함
        let entViewController = EntViewController()
        self.navigationController?.pushViewController(entViewController, animated: true)
    }
}
