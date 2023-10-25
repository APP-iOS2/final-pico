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
        stackView.spacing = 7
        return stackView
    }()

    private lazy var hobbyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: LeftAlignedCollectionViewFlowLayout())
        layout.minimumInteritemSpacing = 3
        layout.estimatedItemSize = .zero
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private lazy var personalCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: LeftAlignedCollectionViewFlowLayout())
        layout.minimumInteritemSpacing = 3
        layout.estimatedItemSize = .zero
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private lazy var mbtiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: LeftAlignedCollectionViewFlowLayout())
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
            make.height.equalTo(50)
        }
        
        hobbyCollectionView.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
            mbtiCollectionView.snp.makeConstraints { make in
                make.height.equalTo(50)
            }
        
    }
}

// MARK: - CollecionView Config
extension SubInfomationViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case personalCollectionView:
            switch personalities.count {
            case 0:
                personalCollectionView.snp.updateConstraints { make in
                    make.height.equalTo(30)
                }
            case 1, 2:
                personalCollectionView.snp.updateConstraints { make in
                    make.height.equalTo(60)
                }
            default:
                personalCollectionView.snp.updateConstraints { make in
                    make.height.equalTo(95)
                }
            }
            return personalities.count
            
        case hobbyCollectionView:
            
            switch hobbies.count {
            case 0:
                hobbyCollectionView.snp.updateConstraints { make in
                    make.height.equalTo(30)
                }
            case 1, 2:
                hobbyCollectionView.snp.updateConstraints { make in
                    make.height.equalTo(60)
                }
            default:
                hobbyCollectionView.snp.updateConstraints { make in
                    make.height.equalTo(60)
                }
            }
            return hobbies.count
            
        case mbtiCollectionView:
            switch likeMbtis.count {
            case 0...5:
                mbtiCollectionView.snp.updateConstraints { make in
                    make.height.equalTo(30)
                }
            case 6...12:
                mbtiCollectionView.snp.updateConstraints { make in
                    make.height.equalTo(60)
                }
            default:
                mbtiCollectionView.snp.updateConstraints { make in
                    make.height.equalTo(100)
                }
            }
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
    
    func updateCollectionViewHeight3(collectionView: UICollectionView, items: [String]) {
        let cellHeight: CGFloat = 25
        var totalCellWidth: CGFloat = 0
        for item in items {
            let label = UILabel()
            label.text = item
            label.sizeToFit()
            totalCellWidth += 50
        }

        let numberOfCellsInRow = view.frame.width / totalCellWidth
        let numberOfRows = Double(numberOfCellsInRow) * Double(items.count)
        let collectionViewHeight: CGFloat = numberOfRows * cellHeight
        
        collectionView.snp.updateConstraints {
            $0.height.equalTo(collectionViewHeight)
        }
    }
    
    func updateCollectionViewHeight(collectionView: UICollectionView, items: [String]) {
        let cellHeight: CGFloat = 50 // 셀의 높이
        var totalCellWidth: CGFloat = 0
        for item in items {
            let label = UILabel()
            label.text = item
            label.sizeToFit()
      
            totalCellWidth += label.frame.width + 10 // 10은 셀 간 여백입니다.
        }

        let numberOfCellsInRow = view.frame.width / totalCellWidth // 한 줄에 표시될 셀의 갯수
        
        let numberOfRows = ceil(CGFloat(items.count) / numberOfCellsInRow) // 필요한 줄의 갯수
        let collectionViewHeight: CGFloat = numberOfRows * cellHeight
        collectionView.snp.updateConstraints {
            $0.height.equalTo(collectionViewHeight)
        }
    }
    
}
