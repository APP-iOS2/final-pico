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
        collectionView.register(LikeCollectionViewCell.self, forCellWithReuseIdentifier: Identifier.CollectionView.likeCell)
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

extension LikeUViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, LikeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.CollectionView.likeCell, for: indexPath) as? LikeCollectionViewCell else { return UICollectionViewCell() }
        cell.configData(imageUrl: imageUrls[indexPath.row], isHiddenDeleteButton: false, isHiddenMessageButton: true)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width / 2 - 17.5
        return CGSize(width: width, height: width * 1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func tappedDeleteButton(_ cell: LikeCollectionViewCell) { }
    
    func tappedMessageButton(_ cell: LikeCollectionViewCell) { 
        // 메시지 연결 작성
    }
}
