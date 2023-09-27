//
//  EntViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import SnapKit

final class EntViewController: UIViewController {
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configLogoBarItem()
        addViews()
        makeConstraints()
        configCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func addViews() {
        [collectionView].forEach { item in
            view.addSubview(item)
        }
    }
    
    private func makeConstraints() {
        let padding: CGFloat = 20
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview().offset(padding)
            make.trailing.equalToSuperview().offset(-padding)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-padding)
        }
    }
    
    private func configCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EntCollectionViewCell.self, forCellWithReuseIdentifier: "GameCell")
        collectionView.register(RandomBoxCell.self, forCellWithReuseIdentifier: "RandomBoxCell")
    }
    
    @objc func tappedRandomBoxButton() {
        let randomBoxViewController = RandomBoxViewController()
        self.navigationController?.pushViewController(randomBoxViewController, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
    
}

extension EntViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sides = (collectionView.bounds.width / 2) - 10
        
        if indexPath.section == 0 {
            return CGSize(width: collectionView.bounds.width, height: sides * 0.6)
        } else {
            return CGSize(width: sides, height: sides * 1.4)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        } else {
            return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RandomBoxCell", for: indexPath) as? RandomBoxCell else { return UICollectionViewCell() }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameCell", for: indexPath) as? EntCollectionViewCell else { return UICollectionViewCell() }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if section == 0 {
            return 20
        } else {
            return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let randomBoxViewController = RandomBoxViewController()
            self.navigationController?.pushViewController(randomBoxViewController, animated: true)
        } else {
            let worldCupViewController = WorldCupViewController()
            self.navigationController?.pushViewController(worldCupViewController, animated: true)
        }
        self.tabBarController?.tabBar.isHidden = true
    }
}
