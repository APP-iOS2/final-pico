//
//  WorldCupViewController.swift
//  Pico
//
//  Created by 오영석 on 2023/09/25.
//

import UIKit
import SnapKit

final class WorldCupViewController: UIViewController {
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "WorldCup"))
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    private let worldCupTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.text = "당신의 친구에게 투표하세요"
        
        return label
    }()
    
    private let pickMeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 36)
        label.text = "Pick Me"
        label.textColor = .picoBlue
        
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "마음에 드는 이성을 골라보세요!\n최종 선택 이성에게 채팅신청 시\n피코가 채팅 신청 피용의 50%를\n부담해 드릴게요!"
        label.numberOfLines = 0
        
        return label
    }()
    
    private let gameStartButton: CommonButton = {
        let button = CommonButton()
        button.setTitle("시작", for: .normal)
        return button
    }()
    
    private let guideLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "24시간에 한 번만 진행 가능합니다"
        label.textColor = .gray
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addViews()
        makeConstraints()
    }
    
    func addViews() {
        [backgroundImageView, worldCupTitleLabel, pickMeLabel, contentLabel, gameStartButton, guideLabel].forEach { item in
            view.addSubview(item)
        }
    }
    
    func makeConstraints() {
        let padding: CGFloat = 20
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        worldCupTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(0.5)
            make.top.equalToSuperview().offset(Screen.height / 5)
        }
        
        pickMeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(0.5)
            make.top.equalTo(worldCupTitleLabel.snp.bottom).offset(padding / 2)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(0.5)
            make.top.equalTo(pickMeLabel.snp.bottom).offset(padding)
        }
        
        gameStartButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(0.5)
            make.top.equalTo(contentLabel.snp.bottom).offset(Screen.height / 10)
            make.leading.equalToSuperview().offset(Screen.width / 4)
            make.trailing.equalToSuperview().offset(-Screen.width / 4)
            make.height.equalTo(Screen.width / 10)
        }
        
        guideLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-padding * 1.5)
        }

    }
}
