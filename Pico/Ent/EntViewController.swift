//
//  EntViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import SnapKit

final class EntViewController: BaseViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let randomBoxView: RandomBoxView = {
        let view = RandomBoxView()
        return view
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        makeConstraints()
        configCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func addViews() {
        [scrollView].forEach { item in
            view.addSubview(item)
        }
        [randomBoxView, collectionView].forEach { item in
            view.addSubview(item)
        }
    }
    
    private func makeConstraints() {
        let padding: CGFloat = 20
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        randomBoxView.snp.makeConstraints { make in
            make.top.equalTo(scrollView).offset(padding)
            make.leading.equalTo(scrollView).offset(padding)
            make.trailing.equalTo(scrollView).offset(-padding)
            make.height.equalTo(scrollView).dividedBy(6.5)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(randomBoxView.snp.bottom).offset(padding)
            make.leading.equalTo(scrollView).offset(padding)
            make.trailing.equalTo(scrollView).offset(-padding)
            make.bottom.equalTo(scrollView).offset(-padding)
        }
    }
    
    private func configCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EntCollectionViewCell.self, forCellWithReuseIdentifier: "GameCell")
    }
    
    @objc func tappedRandomBoxBanner() {
        let randomBoxViewController = RandomBoxViewController()
        self.navigationController?.pushViewController(randomBoxViewController, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
    
}

extension EntViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sides = (collectionView.bounds.width / 2) - 10
        return CGSize(width: sides, height: sides * 1.4)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameCell", for: indexPath) as? EntCollectionViewCell else { return UICollectionViewCell() }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let worldCupViewController = WorldCupViewController()
        self.navigationController?.pushViewController(worldCupViewController, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
}
