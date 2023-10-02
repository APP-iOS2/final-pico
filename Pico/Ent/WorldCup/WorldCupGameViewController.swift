//
//  WorldCupGameViewController.swift
//  Pico
//
//  Created by 오영석 on 2023/09/25.
//
import UIKit
import SnapKit

final class WorldCupGameViewController: UIViewController {
    
    private var items: [User] = DummyUserData.users
    private var strong8: [User] = []
    private var strong4: [User] = []
    private var strong2: [User] = []
    private var winner: [User] = []
    private var index = 0
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "gameBackground"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let roundLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.picoTitleFont
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
        collectionView.layer.cornerRadius = 5
        addShadow()
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumInteritemSpacing = 20
        }
    }
    
    private func addShadow(opacity: Float = 0.07, radius: CGFloat = 5.0) {
        collectionView.layer.masksToBounds = false
        collectionView.layer.shadowColor = UIColor.black.cgColor
        collectionView.layer.shadowOffset = CGSize(width: 10, height: 10)
        collectionView.layer.shadowOpacity = opacity
        collectionView.layer.shadowRadius = radius
    }
    
    private func addViews() {
        [backgroundImageView, roundLabel, contentLabel, collectionView, vsImageView].forEach { item in
            view.addSubview(item)
        }
    }
    
    private func makeConstraints() {
        let padding: CGFloat = 20
        let half: CGFloat = 0.5
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        roundLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Screen.height / 5)
            make.centerX.equalToSuperview().offset(half)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(roundLabel.snp.bottom).offset(padding)
            make.centerX.equalToSuperview().offset(half)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(padding)
            make.leading.equalToSuperview().offset(padding)
            make.trailing.equalToSuperview().offset(-padding)
            make.height.equalTo(view.snp.height).multipliedBy(half)
        }
        
        vsImageView.snp.makeConstraints { make in
            make.centerX.equalTo(collectionView.snp.centerX)
            make.centerY.equalTo(collectionView.snp.centerY).offset(-padding * 1.5)
            make.width.equalTo(25)
            make.height.equalTo(25)
        }
    }
    
    private func addDataLabels(_ currentItem: User) -> [String] {
        var dataLabelTexts: [String] = []
        
        if let height = currentItem.subInfo?.height {
            dataLabelTexts.append("\(height)")
        }
        
        if let job = currentItem.subInfo?.job {
            dataLabelTexts.append("\(job)")
        }
        
        dataLabelTexts.append("\(currentItem.location.address)")
        return dataLabelTexts
    }
    
}

extension WorldCupGameViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WorldCupCollectionViewCell", for: indexPath) as! WorldCupCollectionViewCell
        
        let round: Int
        let currentItem: User
        
        switch index {
        case 0..<16:
            round = 16
            currentItem = items[index + indexPath.item]
        case 16..<24:
            round = 8
            currentItem = strong8[index - 16 + indexPath.item]
        case 24..<28:
            round = 4
            currentItem = strong4[index - 24 + indexPath.item]
        case 28:
            round = 2
            currentItem = strong2[index - 28 + indexPath.item]
        default:
            round = 0
            currentItem = winner[0]
        }
        
        let dataLabelTexts = self.addDataLabels(currentItem)
        
        self.roundLabel.text = round == 2 ? "결승" : "\(round)강"
        cell.mbtiLabel.text = "\(currentItem.mbti)"
        cell.userNickname.text = currentItem.nickName
//        cell.userAge.text = "\(currentItem.age)"
        cell.userInfoStackView.setDataLabelTexts(dataLabelTexts)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 10
        let collectionViewWidth = collectionView.frame.width
        let itemWidth = (collectionViewWidth - (padding * 2)) / 2
        
        return CGSize(width: itemWidth, height: Screen.height * 2 / 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch index {
        case 0..<16:
            let selectedItem = items[index + indexPath.item]
            strong8.append(selectedItem)
            index += 2
            collectionView.reloadData()
        case 16..<24:
            let selectedItem = strong8[index - 16 + indexPath.item]
            strong4.append(selectedItem)
            index += 2
            collectionView.reloadData()
        case 24..<28:
            let selectedItem = strong4[index - 24 + indexPath.item]
            strong2.append(selectedItem)
            index += 2
            collectionView.reloadData()
        default:
            let selectedItem = strong2[index - 28 + indexPath.item]
            winner.append(selectedItem)
        }
    }
}
