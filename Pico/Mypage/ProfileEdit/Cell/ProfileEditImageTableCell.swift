//
//  ProfileEditImageTableCell.swift
//  Pico
//
//  Created by 김민기 on 2023/09/27.
//

import UIKit

final class ProfileEditImageTableCell: UITableViewCell {
    
    private let collectionViewFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 14
        layout.minimumInteritemSpacing = 0
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewFlowLayout)
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.contentInset = .zero
        view.backgroundColor = .clear
        view.register(cell: ProfileEditCollectionCell.self)
        view.register(cell: ProfileEditEmptyCollectionCell.self)
        return view
    }()
    
    private var images = [String]()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configCollectionView()
        addSubView()
        makeConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func config(images: [String]) {
        self.images = images
        collectionView.reloadData()
    }
    
    private func configCollectionView() {
        collectionView.configBackgroundColor()
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func addSubView() {
        [collectionView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.bottom.equalToSuperview()
        }
    }
}

extension ProfileEditImageTableCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < images.count {
            let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath, cellType: ProfileEditCollectionCell.self)
            cell.configure(imageName: self.images[indexPath.row])
            cell.cellConfigure()
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath, cellType: ProfileEditEmptyCollectionCell.self)
            cell.cellConfigure()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.bounds.width / 3) - 25
        let cellHeight = collectionView.bounds.height
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
