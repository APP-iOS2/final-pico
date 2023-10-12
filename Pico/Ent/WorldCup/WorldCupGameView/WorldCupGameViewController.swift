//
//  WorldCupGameViewController.swift
//  Pico
//
//  Created by 오영석 on 2023/09/25.
//
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

final class WorldCupGameViewController: UIViewController {
    
    private var worldCupViewModel = WorldCupViewModel()
    private let disposeBag = DisposeBag()
    private var users = BehaviorRelay<[User]>(value: [])
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
        view.configBackgroundColor()
        addViews()
        makeConstraints()
        configCollectionView()
        configUserData()
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
    
    private func configUserData() {
        worldCupViewModel.users
            .map { $0.prefix(8).map { $0 } }
            .subscribe(onNext: { [weak self] fetchedUsers in
                self?.users.accept(Array(fetchedUsers))
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
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
            make.top.equalTo(contentLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(view.snp.width).multipliedBy(1.2)
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
        return users.value.count / 4
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WorldCupCollectionViewCell", for: indexPath) as? WorldCupCollectionViewCell else { return UICollectionViewCell() }
        
        let index1 = indexPath.item * 2
        let index2 = indexPath.item * 2 + 1
        let user1 = users.value[index1]
        let user2 = users.value[index2]

        worldCupViewModel.configure(cell: cell, with: user1)
        worldCupViewModel.configure(cell: cell, with: user2)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 10
        let collectionViewWidth = collectionView.frame.width
        let itemWidth = (collectionViewWidth - (padding * 2)) / 2

        return CGSize(width: itemWidth, height: Screen.height * 2 / 5)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index1 = indexPath.item * 2
        let index2 = indexPath.item * 2 + 1
        let user1 = users.value[index1]
        let user2 = users.value[index2]
        
        if let cell1 = collectionView.cellForItem(at: IndexPath(item: indexPath.item * 2, section: indexPath.section)) as? WorldCupCollectionViewCell,
           let cell2 = collectionView.cellForItem(at: IndexPath(item: indexPath.item * 2 + 1, section: indexPath.section)) as? WorldCupCollectionViewCell {
            
            worldCupViewModel.configure(cell: cell1, with: user1)
            worldCupViewModel.configure(cell: cell2, with: user2)
        }

        index += 1

        if index == 4 {
            index = 0
            strong4.removeAll()
        } else if index == 2 {
            index = 0
            strong2.removeAll()
        } else if index == 1 {
            print(users)
        }
        collectionView.reloadData()
    }

}
