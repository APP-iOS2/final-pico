//
//  LikeUViewController.swift
//  Pico
//
//  Created by 방유빈 on 2023/09/25.
//

import UIKit

final class LikeUViewController: UIViewController {
    private let emptyView: LikeEmptyView = LikeEmptyView(type: .iLikeU)
    private let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let imageUrls: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        makeConstraints()
        configButtons()
        configCollectionView()
    }
    
    private func configCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(LikeCollectionViewCell.self, forCellWithReuseIdentifier: LikeCollectionViewCell.identifier)
    }
    
    private func configButtons() {
        emptyView.linkButton.addTarget(self, action: #selector(tappedLinkButton), for: .touchUpInside)
    }
    
    private func addViews() {
        if imageUrls.isEmpty {
            view.addSubview(emptyView)
        } else {
            view.addSubview(collectionView)
        }
    }
    
    private func makeConstraints() {
        if imageUrls.isEmpty {
            emptyView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        } else {
            collectionView.snp.makeConstraints { make in
                make.top.leading.equalToSuperview().offset(10)
                make.trailing.bottom.equalToSuperview().offset(-10)
            }
        }
    }
    
    @objc func tappedLinkButton(_ sender: UIButton) {
        if let tabBarController = self.tabBarController as? TabBarController {
            tabBarController.selectedIndex = 0
        }
    }
}

extension LikeUViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LikeCollectionViewCell.identifier, for: indexPath) as? LikeCollectionViewCell else { return UICollectionViewCell() }
        cell.configData(imageUrl: imageUrls[indexPath.row], isHiddenDeleteButton: true, isHiddenMessageButton: false)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width / 2 - 20
        return CGSize(width: width, height: width * 1.5)
    }
}
