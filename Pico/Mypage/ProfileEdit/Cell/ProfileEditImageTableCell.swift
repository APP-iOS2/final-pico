//
//  ProfileEditImageTableCell.swift
//  Pico
//
//  Created by 김민기 on 2023/09/27.
//

import UIKit
import SnapKit
import PhotosUI

protocol ProfileEditImageDelegate: AnyObject {
    func presentPickerView()
    func presentCustomAlert(messageText: String)
}

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
        view.accessibilityLabel = "사진추가"
        view.isAccessibilityElement = true
        view.register(cell: ProfileEditCollectionCell.self)
        view.register(cell: ProfileEditEmptyCollectionCell.self)
        return view
    }()
    
    weak var profileEditImageDelegate: ProfileEditImageDelegate?
    private var images = [String]()
    private var profileEditViewModel: ProfileEditViewModel?
    
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
    
    func config(images: [String], viewModel: ProfileEditViewModel) {
        self.images = images
        profileEditViewModel = viewModel
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
    @objc private func tappedDeleteButton(_ sender: UIButton) {
        guard images.count > 1 else {
            profileEditImageDelegate?.presentCustomAlert(messageText: "최소 한개 이상의 사진을 등록해 주세요.")
            return
        }
        let index = sender.tag
        images.remove(at: index)
        profileEditViewModel?.modalType = .imageURLs
        profileEditViewModel?.collectionData = images
        profileEditViewModel?.updateData(data: images)

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
            cell.deleteButton.tag = indexPath.row
            cell.deleteButton.addTarget(self, action: #selector(tappedDeleteButton), for: .touchUpInside)
            cell.cellConfigure()
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath, cellType: ProfileEditEmptyCollectionCell.self)
            cell.cellConfigure()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth: CGFloat = (collectionView.bounds.width / 3) - 20
        let cellHeight = collectionView.bounds.height
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard images.count < 3 else {
            profileEditImageDelegate?.presentCustomAlert(messageText: "사진은 최대 3개까지 등록가능합니다.")
            return
        }
        if images.count == indexPath.row {
            profileEditViewModel?.modalType = .imageURLs
            profileEditViewModel?.collectionData = images
            profileEditImageDelegate?.presentPickerView()
        }
    }
}
