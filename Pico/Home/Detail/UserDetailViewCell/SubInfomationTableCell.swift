//
//  BottomUserDetailViewController.swift
//  Pico
//
//  Created by 신희권 on 2023/09/26.
//

import UIKit
import SnapKit

final class SubInfomationTableCell: UITableViewCell {
    private let viewModel = UserDetailViewModel()
    
    private let hobbyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        layout.minimumInteritemSpacing = 5
        return collectionView
    }()
    
    private let personalCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        layout.minimumInteritemSpacing = 5
        return collectionView
    }()
    
    private let mbtiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        layout.minimumInteritemSpacing = 5
        return collectionView
    }()
    
    private let hobbyLabel: UILabel = {
        let label = UILabel()
        label.text = "내 취미"
        label.font = UIFont.picoSubTitleFont
        return label
    }()
    
    private let personalLabel: UILabel = {
        let label = UILabel()
        label.text = "내 성격"
        label.font = UIFont.picoSubTitleFont
        return label
    }()
    
    private let likeMbtiLable: UILabel = {
        let label = UILabel()
        label.text = "선호하는 MBTI"
        label.font = UIFont.picoSubTitleFont
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addViews()
        makeConstraints()
        configCollectionView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configCollectionView() {
        hobbyCollectionView.register(HobbyCollectionViewCell.self, forCellWithReuseIdentifier: Identifier.CollectionView.hobbyCollectionCell)
        hobbyCollectionView.delegate = self
        hobbyCollectionView.dataSource = self
        
        personalCollectionView.register(HobbyCollectionViewCell.self, forCellWithReuseIdentifier: Identifier.CollectionView.hobbyCollectionCell)
        personalCollectionView.delegate = self
        personalCollectionView.dataSource = self
        
        mbtiCollectionView.register(MbtiCollectionViewCell.self, forCellWithReuseIdentifier: Identifier.CollectionView.mbtiCollectionCell)
        mbtiCollectionView.delegate = self
        mbtiCollectionView.dataSource = self
    }
    
    private func addViews() {
        [hobbyLabel, personalLabel, hobbyCollectionView, personalCollectionView, likeMbtiLable, mbtiCollectionView].forEach {
            self.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        hobbyLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(20)
        }
        
        hobbyCollectionView.snp.makeConstraints { make in
            make.top.equalTo(hobbyLabel.snp.bottom).offset(20)
            make.leading.equalTo(hobbyLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-10)
            
            make.height.equalTo(Screen.height * 0.1)
        }
        
        personalLabel.snp.makeConstraints { make in
            make.top.equalTo(hobbyCollectionView.snp.bottom).offset(20)
            make.leading.equalTo(hobbyLabel.snp.leading)
            make.trailing.equalToSuperview()
        }
        
        personalCollectionView.snp.makeConstraints { make in
            make.top.equalTo(personalLabel.snp.bottom).offset(20)
            make.leading.equalTo(personalLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(Screen.height * 0.1)
        }
        
        likeMbtiLable.snp.makeConstraints { make in
            make.top.equalTo(personalCollectionView.snp.bottom).offset(20)
            make.leading.equalTo(hobbyLabel.snp.leading)
            make.trailing.equalToSuperview()
            
        }
        
        mbtiCollectionView.snp.makeConstraints { make in
            make.top.equalTo(likeMbtiLable.snp.bottom).offset(20)
            make.leading.equalTo(likeMbtiLable.snp.leading)
            make.trailing.bottom.equalToSuperview()
            
        }
    }
}

extension SubInfomationTableCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let hobbys = viewModel.userData.subInfo?.hobbies else { return 0 }
        guard let personal = viewModel.userData.subInfo?.personalities else { return 0 }
        guard let mbtis = viewModel.userData.subInfo?.favoriteMBTIs else { return 0 }
        
        switch collectionView {
        case hobbyCollectionView:
            return hobbys.count
            
        case personalCollectionView:
            return personal.count
            
        case mbtiCollectionView:
            return mbtis.count
        default:
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView {
            
        case hobbyCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.CollectionView.hobbyCollectionCell, for: indexPath) as? HobbyCollectionViewCell else { return UICollectionViewCell() }
            guard let hobbys = viewModel.userData.subInfo?.hobbies else { return UICollectionViewCell() }
            
            cell.config(labelText: hobbys[indexPath.row])
            return cell
            
        case personalCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.CollectionView.hobbyCollectionCell, for: indexPath) as? HobbyCollectionViewCell else { return UICollectionViewCell() }
            guard let personal = viewModel.userData.subInfo?.personalities else { return UICollectionViewCell() }
            cell.config(labelText: personal[indexPath.row])
            return cell
            
        case mbtiCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.CollectionView.mbtiCollectionCell, for: indexPath) as? MbtiCollectionViewCell else { return UICollectionViewCell() }
            guard let mbtis = viewModel.userData.subInfo?.favoriteMBTIs else { return UICollectionViewCell() }
            cell.config(mbtiType: mbtis[indexPath.row])
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        switch collectionView {
            
        case hobbyCollectionView:
            let hobby = viewModel.userData.subInfo?.hobbies[indexPath.row]
            label.text = hobby
            label.sizeToFit()
            let size = label.frame.size
            return CGSize(width: size.width + 5, height: size.height + 8)
            
        case personalCollectionView:
            let personal = viewModel.userData.subInfo?.personalities[indexPath.row]
            label.text = personal
            label.sizeToFit()
            let size = label.frame.size
            return CGSize(width: size.width + 8, height: size.height + 8)
            
        case mbtiCollectionView:
            return CGSize(width: 70, height: 30)
            
        default:
            return CGSize(width: 70, height: 70)
        }
    }
}
