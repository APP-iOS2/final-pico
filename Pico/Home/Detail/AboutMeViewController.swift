//
//  MiddleUserDetailViewController.swift
//  Pico
//
//  Created by 신희권 on 2023/09/25.
//

import UIKit
import SnapKit

final class AboutMeViewController: UIViewController {
    private var cellInfomation: [[String]] = [["", ""]]
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 5
        return stackView
    }()
    
    private let basicLabel: UILabel = {
        let label = UILabel()
        label.text = "기본 정보"
        label.font = UIFont.picoSubTitleFont
        return label
    }()
    
    private var aboutMeCollectionView: UICollectionView = {
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
    func config(eduText: String?, religionText: String?, smokeText: String?, jobText: String?, drinkText: String?) {
        
        cellInfomation.removeAll()
        
        let infoArray: [(icon: String, text: String?)] = [
            ("graduationcap", eduText),
            ("religion", religionText),
            ("smoke", smokeText),
            ("case", jobText),
            ("wineglass", drinkText)
        ]
        
        // nil이 아닌 항목만 필터링하고, 옵셔널 바인딩을 사용하여 값 추출
        cellInfomation = infoArray.compactMap { icon, text in
            guard let text = text else { return nil }
            return [icon, text]
        }
        
        print(cellInfomation.count)
        
        if cellInfomation.isEmpty {
            aboutMeCollectionView.isHidden = true
            basicLabel.isHidden = true
            view.isHidden = true
        } else {
            updateConstraints()
        }
        
        aboutMeCollectionView.reloadData()
    }
    
    private func configCollectionView() {
        aboutMeCollectionView.register(AboutMeCollectionViewCell.self, forCellWithReuseIdentifier: "aboutMeCollectionViewCell")
        aboutMeCollectionView.delegate = self
        aboutMeCollectionView.dataSource = self
        
//        if let layout = aboutMeCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            layout.minimumInteritemSpacing = 2
//            layout.minimumLineSpacing = 2
//            let itemWidth = view.frame.width / 2.5
//            layout.itemSize = CGSize(width: itemWidth, height: 35)
//        }
    }
    
    private func updateConstraints() {
        var height: Int = 0
        switch cellInfomation.count {
        case 0:
            height = 0
        case 1, 2:
            height = 50
        case 3, 4:
            height = 100
        default:
            height = 150
        }
        aboutMeCollectionView.snp.remakeConstraints { make in
            make.top.equalTo(basicLabel.snp.bottom).offset(15)
            make.height.equalTo(height)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - UI 관련
extension AboutMeViewController {
    private func addViews() {
        view.addSubview([aboutMeCollectionView, basicLabel])
    }
    
    private func makeConstraints() {
    
        basicLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        aboutMeCollectionView.snp.makeConstraints { make in
            make.top.equalTo(basicLabel.snp.bottom).offset(15)
            make.height.equalTo(150)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension AboutMeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellInfomation.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "aboutMeCollectionViewCell", for: indexPath) as? AboutMeCollectionViewCell else { return UICollectionViewCell() }
        cell.config(image: cellInfomation[indexPath.row][0], title: cellInfomation[indexPath.row][1])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width / 2 - 20, height: 35)
    }
}
