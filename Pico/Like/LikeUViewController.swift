//
//  LikeUViewController.swift
//  Pico
//
//  Created by 방유빈 on 2023/09/25.
//

import UIKit

final class LikeUViewController: UIViewController {
    private let emptyView: EmptyViewController = EmptyViewController(type: .iLikeU)
    private let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let imageUrls: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        makeConstraints()
        configCollectionView()
    }
    
    private func configCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(LikeCollectionViewCell.self, forCellWithReuseIdentifier: Identifier.CollectionView.likeCell)
    }
    
    private func addViews() {
        if imageUrls.isEmpty {
            addChild(emptyView)
            view.addSubview(emptyView.view)
            emptyView.didMove(toParent: self)
        } else {
            view.addSubview(collectionView)
        }
    }
    
    private func makeConstraints() {
        if imageUrls.isEmpty {
            emptyView.view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        } else {
            collectionView.snp.makeConstraints { make in
                make.top.leading.equalToSuperview().offset(10)
                make.trailing.bottom.equalToSuperview().offset(-10)
            }
        }
    }
}

extension LikeUViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.CollectionView.likeCell, for: indexPath) as? LikeCollectionViewCell else { return UICollectionViewCell() }
//        cell.configData(imageUrl: imageUrls[indexPath.row], isHiddenDeleteButton: false, isHiddenMessageButton: true)
//        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width / 2 - 17.5
        return CGSize(width: width, height: width * 1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
}

// extension LikeUViewController: LikeCollectionViewCellDelegate {
//    func tappedDeleteButton(_ cell: LikeCollectionViewCell) { }
//    
//    func tappedMessageButton(_ cell: LikeCollectionViewCell) {
//        // 메시지 연결 작성
//    }
// }
