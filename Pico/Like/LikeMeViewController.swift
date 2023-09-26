//
//  LikeMeViewController.swift
//  Pico
//
//  Created by 방유빈 on 2023/09/25.
//

import UIKit

final class LikeMeViewController: UIViewController {
    private let emptyView: UIView = LikeEmptyView(type: .uLikeMe)
    private let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var imageUrls = ["https://image5jvqbd.fmkorea.com/files/attach/new2/20211225/3655109/3113058505/4195166827/e130faca7194985e4f162b3583d52853.jpg",
                     "https://img.dmitory.com/img/202107/2lh/a8H/2lha8HnRr6Q046GGGQ0uwM.jpg",
                     "https://i.namu.wiki/i/jUHcYJjORbNSurOw8cwl-g8jduAT01mhJJkF5oDbvyae_1hkSExnUQ0I5fDKgebUKzSFjSFhRheeSI9-rfpuDU8RJ9wqo5KwIodMVjuzKT2o6RK0IutUtsKWZrYxzT-cOvxKhbPm9c3PXo5H-OvBCA.webp"]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
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
}

extension LikeMeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, LikeCollectionViewCellDelegate {
    
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
        let width = view.frame.width / 2 - 20
        return CGSize(width: width, height: width * 1.5)
    }
    
    func tappedDeleteButton(_ cell: LikeCollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            imageUrls.remove(at: indexPath.item)
            collectionView.deleteItems(at: [indexPath])
        }
    }
    
    func tappedMessageButton(_ cell: LikeCollectionViewCell) { }
}
