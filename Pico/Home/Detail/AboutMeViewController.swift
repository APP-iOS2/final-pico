//
//  MiddleUserDetailViewController.swift
//  Pico
//
//  Created by 신희권 on 2023/09/25.
//

import UIKit

final class AboutMeViewController: UIViewController {
    private var cellInfomation: [[String]] = [["", ""]]
////    private let verticalStackView: UIStackView = {
////        let stackView = UIStackView()
////        stackView.axis = .vertical
////        stackView.distribution = .fillProportionally
////        stackView.alignment = .fill
////        stackView.spacing = 10
////        return stackView
////    }()
//    
//    private let introLabelContainerView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .picoGray
//        view.layer.masksToBounds = true
//        view.layer.cornerRadius = 10
//        return view
//    }()
    
    private let introLabel: UILabel = {
        let label = PaddingLabel(padding: UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 5))
        label.text = ""
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = .picoGray
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        return label
    }()
    
    private let basicLabel: UILabel = {
        let label = UILabel()
        label.text = "기본 정보"
        label.font = UIFont.picoSubTitleFont
        return label
    }()
    
     private lazy var aboutMeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        makeConstraints()
        configCollectionView()
    }
    
    // MARK: - Config
    func config(intro: String?, eduText: String?, religionText: String?, smokeText: String?, jobText: String?, drinkText: String?) {
        var allNil = true
        
        if let intro = intro {
            introLabel.text = intro
            allNil = false
        } else {
            introLabel.text = nil
            introLabel.isHidden = true
        }
        
        cellInfomation.removeAll()
        
        let infoArray: [(icon: String, text: String?)] = [
            ("graduationcap", eduText),
            ("religion", religionText),
            ("smoke", smokeText),
            ("bag", jobText),
            ("wineglass", drinkText)
        ]

        // nil이 아닌 항목만 필터링하고, 옵셔널 바인딩을 사용하여 값 추출
        cellInfomation = infoArray.compactMap { icon, text in
            guard let text = text else { return nil }
            allNil = false // 변수가 하나라도 nil이 아닌 값을 가지고 있으면 allNil을 false로 설정
            return [icon, text]
        }
        
        if cellInfomation.isEmpty {
            aboutMeCollectionView.isHidden = true
            basicLabel.isHidden = true
        }

        // 모든 변수가 nil인 경우 뷰를 숨김
        view.isHidden = allNil

        aboutMeCollectionView.reloadData()
    }
    
    private func configCollectionView() {
        aboutMeCollectionView.register(AboutMeCollectionViewCell.self, forCellWithReuseIdentifier: "aboutMeCollectionViewCell")
        aboutMeCollectionView.delegate = self
        aboutMeCollectionView.dataSource = self
        
        if let layout = aboutMeCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.minimumInteritemSpacing = 2
                layout.minimumLineSpacing = 2
                let itemWidth = (view.frame.width - 20) / 3
                layout.itemSize = CGSize(width: itemWidth, height: 40)
            }
    }
    
}

// MARK: - UI 관련
extension AboutMeViewController {
    private func addViews() {

        [introLabel, aboutMeCollectionView, basicLabel].forEach { view.addSubview($0) }
    }
    
    private func makeConstraints() {
//        introLabelContainerView.snp.makeConstraints { make in
//            make.equalToSuperview()
//        }
        
        introLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        basicLabel.snp.makeConstraints { make in
            make.top.equalTo(introLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
        }
        
        aboutMeCollectionView.snp.makeConstraints { make in
            make.top.equalTo(basicLabel.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
           // make.height.equalTo(120)
        }
    }
}

extension AboutMeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellInfomation.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "aboutMeCollectionViewCell", for: indexPath) as? AboutMeCollectionViewCell else { return UICollectionViewCell() }
            cell.config(image: cellInfomation[indexPath.row][0], title: cellInfomation[indexPath.row][1])
        return cell
    }
    
}
