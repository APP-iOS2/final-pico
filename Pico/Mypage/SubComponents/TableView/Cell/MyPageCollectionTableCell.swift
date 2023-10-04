//
//  MyPageCollectionTableCell.swift
//  Pico
//
//  Created by 김민기 on 2023/09/26.
//

import UIKit

protocol MyPageDelegate: AnyObject {
    func didSelectItem(item: Int)
}

final class MyPageCollectionTableCell: UITableViewCell {
    
    weak var delegate: MyPageDelegate?
    
    private let collectionViewFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 18
        layout.minimumInteritemSpacing = 0
        return layout
    }()
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewFlowLayout)
        view.isScrollEnabled = false
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.contentInset = .zero
        view.register(MyPageCollectionCell.self, forCellWithReuseIdentifier: Identifier.CollectionView.myPageCollectionCell)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configCollectionView()
        addSubView()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func configCollectionView() {
        collectionView.backgroundColor = .picoLightGray
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.addShadow(offset: CGSize(width: 1, height: 1), color: .black, opacity: 0.07, radius: 3.0)
        collectionView.layer.masksToBounds = true
    }
    
    private func addSubView() {
        [collectionView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}

extension MyPageCollectionTableCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.CollectionView.myPageCollectionCell, for: indexPath) as? MyPageCollectionCell else { return UICollectionViewCell() }
        cell.configure(imageName: "chu", title: "Store", subTitle: "돈을 주세요")
        cell.backgroundColor = .white
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 10
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.bounds.width / 2) - 10
        let cellHeight = collectionView.bounds.height
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        default:
            delegate?.didSelectItem(item: 0)
        }
    }
}
