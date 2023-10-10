//
//  asd.swift
//  Pico
//
//  Created by 임대진 on 2023/09/27.
//

import UIKit

final class MBTICollectionViewController: UIViewController {
    private let columns = 4
    private let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        makeConstraints()
        configCollectionView()
    }
    
    private func configCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cell: MBTILabelCollectionViewCell.self)
    }
    
    private func addViews() {
            view.addSubview(collectionView)
    }
    
    private func makeConstraints() {
            collectionView.snp.makeConstraints { make in
                make.top.leading.equalToSuperview()
                make.trailing.bottom.equalToSuperview()
        }
    }
}
extension MBTICollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MBTIType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath, cellType: MBTILabelCollectionViewCell.self)
        let mbti = MBTIType.allCases[indexPath.item]
        cell.configureWithMBTI(mbti)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width - CGFloat(columns - 1) * 10) / CGFloat(columns)
        return CGSize(width: cellWidth, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
