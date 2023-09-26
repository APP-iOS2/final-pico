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
        let imageView = UIImageView(image: UIImage(named: "gameBackground"))
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
        label.font = UIFont.picoButtonFont
        label.text = "마음에 드는 이성을 골라보세요!"
        
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        return collectionView
    }()
    
    private let vsImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "vsImage"))
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addViews()
        makeConstraints()
        configCollectionView()
    }
    
    private func configCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(WorldCupCollectionViewCell.self, forCellWithReuseIdentifier: "WorldCupCollectionViewCell")
        collectionView.backgroundColor = .clear
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumInteritemSpacing = 20
        }
        collectionView.layer.masksToBounds = false
        collectionView.layer.shadowColor = UIColor.black.cgColor
        collectionView.layer.shadowOpacity = 0.3
        collectionView.layer.shadowOffset = CGSize(width: 0, height: 2)
        collectionView.layer.shadowRadius = 10
        collectionView.layer.cornerRadius = 10
    }

    private func addViews() {
        [backgroundImageView, roundLabel, contentLabel, collectionView, vsImageView].forEach { item in
            view.addSubview(item)
        }
    }
    
    private func makeConstraints() {
        let padding: CGFloat = 20
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        roundLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Screen.height / 5)
            make.centerX.equalToSuperview().offset(0.5)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(roundLabel.snp.bottom).offset(padding)
            make.centerX.equalToSuperview().offset(0.5)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(padding)
            make.leading.equalToSuperview().offset(padding)
            make.trailing.equalToSuperview().offset(-padding)
            make.height.equalTo(view.snp.height).multipliedBy(0.5)
        }
        
        vsImageView.snp.makeConstraints { make in
            make.centerX.equalTo(collectionView.snp.centerX)
            make.centerY.equalTo(collectionView.snp.centerY).offset(-padding * 1.5)
            make.width.equalTo(25)
            make.height.equalTo(25)
        }
    }
    
}

extension WorldCupGameViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WorldCupCollectionViewCell", for: indexPath) as! WorldCupCollectionViewCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 10
        let collectionViewWidth = collectionView.frame.width
        let itemWidth = (collectionViewWidth - (padding * 2)) / 2
        
        return CGSize(width: itemWidth, height: Screen.height / 2)
    }
}
