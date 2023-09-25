//
//  EntViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import SnapKit

final class EntViewController: UIViewController {

    private let randomBoxButton: RandomBoxBanner = {
        let button = RandomBoxBanner()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(EntCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        addViews()
        setLayoutConstraints()
    }

    func addViews() {
        [randomBoxButton, collectionView].forEach { item in
            view.addSubview(item)
        }
    }

    func setLayoutConstraints() {
        let padding: CGFloat = 20
        
        randomBoxButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(padding)
            make.leading.trailing.equalToSuperview().inset(padding)
            make.height.equalTo(padding * 5)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(randomBoxButton.snp.bottom).offset(padding)
            make.leading.equalTo(randomBoxButton.snp.leading)
            make.trailing.equalTo(randomBoxButton.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-padding)
        }
    }
}

extension EntViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sides = (collectionView.bounds.width / 2) - 10
        
        return CGSize(width: sides, height: sides * 1.4)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! EntCollectionViewCell

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
