//
//  SubInfomationViewController.swift
//  Pico
//
//  Created by 신희권 on 2023/09/26.
//

import UIKit
import RxSwift

final class SubInfomationViewController: UIViewController {
    private var hobbies: [String] = []
    private var personalities: [String] = []
    private var likeMbtis: [MBTIType] = []
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()
    
    private let hobbyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.minimumInteritemSpacing = 3
        layout.estimatedItemSize = .zero
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private let personalCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.minimumInteritemSpacing = 3
        layout.estimatedItemSize = .zero
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private let mbtiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.minimumInteritemSpacing = 5
        collectionView.isScrollEnabled = false
        layout.estimatedItemSize = .zero

        return collectionView
    }()
    
    private let hobbyLabel: UILabel = {
        let label = UILabel()
        label.text = "취미"
        label.font = UIFont.picoSubTitleFont
        return label
    }()
    
    private let personalLabel: UILabel = {
        let label = UILabel()
        label.text = "성격"
        label.font = UIFont.picoSubTitleFont
        return label
    }()
    
    private let likeMbtiLabel: UILabel = {
        let label = UILabel()
        label.text = "선호 MBTI"
        label.font = UIFont.picoSubTitleFont
        return label
    }()
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        makeConstraints()
        configCollectionView()
    }
    
    // MARK: - Config
    func config(hobbies: [String]?, personalities: [String]?, likeMbtis: [MBTIType]?) {
        if hobbies == nil && personalities == nil && likeMbtis == nil {
            view.isHidden = true
        }
        
        if let personalities {
            self.personalities = personalities
        } else {
            personalLabel.isHidden = true
            personalCollectionView.isHidden = true
            verticalStackView.removeArrangedSubview(personalLabel)
            verticalStackView.removeArrangedSubview(personalCollectionView)
        }
        
        if let hobbies {
            self.hobbies = hobbies
        } else {
            hobbyLabel.isHidden = true
            hobbyCollectionView.isHidden = true
            verticalStackView.removeArrangedSubview(hobbyLabel)
            verticalStackView.removeArrangedSubview(hobbyCollectionView)
        }
        
        if let likeMbtis {
            self.likeMbtis = likeMbtis
        } else {
            likeMbtiLabel.isHidden = true
            mbtiCollectionView.isHidden = true
            verticalStackView.removeArrangedSubview(likeMbtiLabel)
            verticalStackView.removeArrangedSubview(mbtiCollectionView)
        }
        
        hobbyCollectionView.reloadData()
        personalCollectionView.reloadData()
        mbtiCollectionView.reloadData()
    }
    
    private func configCollectionView() {
        hobbyCollectionView.register(HobbyCollectionViewCell.self, forCellWithReuseIdentifier: "hobbyCollectionCell")
        hobbyCollectionView.delegate = self
        hobbyCollectionView.dataSource = self
        
        personalCollectionView.register(HobbyCollectionViewCell.self, forCellWithReuseIdentifier: "hobbyCollectionCell")
        personalCollectionView.delegate = self
        personalCollectionView.dataSource = self
        
        mbtiCollectionView.register(MbtiCollectionViewCell.self, forCellWithReuseIdentifier: "mbtiCollectionCell")
        mbtiCollectionView.delegate = self
        mbtiCollectionView.dataSource = self
    
    }
}
// MARK: - UI관련
extension SubInfomationViewController {
    
    private func addViews() {
        view.addSubview(verticalStackView)
        [personalLabel, personalCollectionView, hobbyLabel, hobbyCollectionView, likeMbtiLabel, mbtiCollectionView].forEach {
            verticalStackView.addArrangedSubview($0)
        }
    }
    
    private func makeConstraints() {
        verticalStackView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        personalLabel.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        hobbyLabel.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
        likeMbtiLabel.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
        personalCollectionView.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        
        hobbyCollectionView.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        
        mbtiCollectionView.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
    }
}

// MARK: - CollecionView Config
extension SubInfomationViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
            
        case hobbyCollectionView:
            return hobbies.count
            
        case personalCollectionView:
            return personalities.count
            
        case mbtiCollectionView:
            return likeMbtis.count
        default:
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case hobbyCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hobbyCollectionCell", for: indexPath) as? HobbyCollectionViewCell else { return UICollectionViewCell() }
            cell.config(labelText: hobbies[indexPath.row])
            return cell
            
        case personalCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hobbyCollectionCell", for: indexPath) as? HobbyCollectionViewCell else { return UICollectionViewCell() }
            
            cell.config(labelText: personalities[indexPath.row])
            return cell
            
        case mbtiCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mbtiCollectionCell", for: indexPath) as? MbtiCollectionViewCell else { return UICollectionViewCell() }
            
            cell.config(mbtiType: likeMbtis[indexPath.row])
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        switch collectionView {
            
        case hobbyCollectionView:
            let hobby = hobbies[indexPath.row]
            label.text = hobby
            label.sizeToFit()
            let size = label.frame.size
            return CGSize(width: size.width + 10, height: size.height + 8)
            
        case personalCollectionView:
            let personal = personalities[indexPath.row]
            label.text = personal
            label.sizeToFit()
            let size = label.frame.size
            return CGSize(width: size.width + 10, height: size.height + 8)
            
        case mbtiCollectionView:
            return CGSize(width: 50, height: 25)
            
        default:
            return CGSize(width: 65, height: 70)
        }
    }
    
}
