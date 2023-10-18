//
//  SubInfomationViewController.swift
//  Pico
//
//  Created by 신희권 on 2023/09/26.
//

import UIKit
import RxSwift

final class SubInfomationViewController: BaseViewController {
    private var hobbies: [String] = []
    private var personalities: [String] = []
    private var likeMbtis: [MBTIType] = []
    
    //    private let verticalStackView: UIStackView = {
    //        let stackView = UIStackView()
    //        stackView.axis = .vertical
    //        stackView.distribution = .fillProportionally
    //        stackView.alignment = .fill
    //        return stackView
    //    }()
    
    private let hobbyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.minimumInteritemSpacing = 3
        return collectionView
    }()
    
    private let personalCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.minimumInteritemSpacing = 3
        return collectionView
    }()
    
    private let mbtiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.minimumInteritemSpacing = 3
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
    
    private let likeMbtiLabel: UILabel = {
        let label = UILabel()
        label.text = "선호하는 MBTI"
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
            personalLabel.removeFromSuperview()
            personalCollectionView.removeFromSuperview()
        }
        
        if let hobbies {
            self.hobbies = hobbies
        } else {
            hobbyLabel.removeFromSuperview()
            hobbyCollectionView.removeFromSuperview()
        }
        
        if let likeMbtis {
            self.likeMbtis = likeMbtis
        } else {
            likeMbtiLabel.removeFromSuperview()
            mbtiCollectionView.removeFromSuperview()
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
        [personalLabel, personalCollectionView, hobbyLabel, hobbyCollectionView, likeMbtiLabel, mbtiCollectionView].forEach {
            view.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        
        //        verticalStackView.snp.makeConstraints { make in
        //            make.edges.equalToSuperview()
        //        }
        
        personalLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview()
        }
        //
        personalCollectionView.snp.makeConstraints { make in
            make.top.equalTo(personalLabel.snp.bottom).offset(20)
            make.leading.equalTo(personalLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-20)
            
            make.height.equalTo(Screen.height * 0.2)
        }
        
        hobbyLabel.snp.makeConstraints { make in
            make.top.equalTo(personalCollectionView.snp.bottom).offset(20)
            make.leading.equalTo(personalLabel.snp.leading)
            make.trailing.equalToSuperview()
        }
        
        hobbyCollectionView.snp.makeConstraints { make in
            make.top.equalTo(hobbyLabel.snp.bottom).offset(20)
            make.leading.equalTo(hobbyLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(Screen.height * 0.2)
        }
        
        likeMbtiLabel.snp.makeConstraints { make in
            make.top.equalTo(hobbyCollectionView.snp.bottom).offset(20)
            make.leading.equalTo(hobbyLabel.snp.leading)
            make.trailing.equalToSuperview()
            
        }
        
        mbtiCollectionView.snp.makeConstraints { make in
            make.top.equalTo(likeMbtiLabel.snp.bottom).offset(20)
            make.leading.equalTo(likeMbtiLabel.snp.leading)
            make.trailing.equalToSuperview()
            make.height.equalTo(Screen.height * 0.2)
            
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
            return CGSize(width: size.width + 5, height: size.height + 8)
            
        case personalCollectionView:
            let personal = personalities[indexPath.row]
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
