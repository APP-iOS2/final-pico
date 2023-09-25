//
//  WorldCupGameViewController.swift
//  Pico
//
//  Created by 오영석 on 2023/09/25.
//

import UIKit
import SnapKit

final class WorldCupGameViewController: UIViewController {
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "WorldCup"))
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    private let roundLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.text = "16강"
        
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "마음에 드는 이성을 골라보세요!"
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addViews()
        makeConstraints()
    }
    
    func addViews() {
        [backgroundImageView, roundLabel, contentLabel].forEach { item in
            view.addSubview(item)
        }
    }
    
    func makeConstraints() {
        let padding: CGFloat = 20
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        roundLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(0.5)
            make.top.equalToSuperview().offset(Screen.height / 5)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(0.5)
            make.top.equalTo(roundLabel.snp.bottom).offset(padding)
        }
    }
}
