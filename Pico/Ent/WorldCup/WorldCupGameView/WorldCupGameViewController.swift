//
//  WorldCupGameViewController.swift
//  Pico
//
//  Created by 오영석 on 2023/09/25.
//
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

final class WorldCupGameViewController: UIViewController {
    
    private let viewModel = WorldCupViewModel()
    private let disposeBag = DisposeBag()
    
    private var items: [User] = DummyUserData.users
    private var strong8: [User] = []
    private var strong4: [User] = []
    private var strong2: [User] = []
    private var index = 0
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "gameBackground"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let roundLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.picoTitleFont
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.picoButtonFont
        label.text = "마음에 드는 이성을 골라보세요!"
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    private let vsImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "vsImage"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.configBackgroundColor()
        addViews()
        makeConstraints()
        configCollectionView()
        bindViewModel()
    }
    
    private func configCollectionView() {
        collectionView.register(WorldCupCollectionViewCell.self, forCellWithReuseIdentifier: "WorldCupCollectionViewCell")
        collectionView.backgroundColor = .clear
        collectionView.layer.cornerRadius = 5
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let cellWidth = (UIScreen.main.bounds.width - 40 - 20) / 2
            layout.itemSize = CGSize(width: cellWidth, height: cellWidth * 1.2)
            layout.minimumInteritemSpacing = 20
            layout.minimumLineSpacing = 20
        }
    }
    
    private func bindViewModel() {
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, User>>(
            configureCell: { [weak self] _, collectionView, indexPath, item in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WorldCupCollectionViewCell", for: indexPath) as? WorldCupCollectionViewCell else { return UICollectionViewCell() }
                let dataLabelTexts = self?.viewModel.addDataLabels(item) ?? []
                cell.mbtiLabel.text = "\(item.mbti)"
                cell.userNickname.text = item.nickName
                cell.userInfoStackView.setDataLabelTexts(dataLabelTexts)
                return cell
            }
        )
        
        viewModel.items
            .map { [SectionModel(model: "", items: Array($0.prefix(2)))] }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    private func addShadow(opacity: Float = 0.07, radius: CGFloat = 5.0) {
        collectionView.layer.masksToBounds = false
        collectionView.layer.shadowColor = UIColor.black.cgColor
        collectionView.layer.shadowOffset = CGSize(width: 10, height: 10)
        collectionView.layer.shadowOpacity = opacity
        collectionView.layer.shadowRadius = radius
    }
    
    private func addViews() {
        [backgroundImageView, roundLabel, contentLabel, collectionView, vsImageView].forEach { item in
            view.addSubview(item)
        }
    }
    
    private func makeConstraints() {
        let padding: CGFloat = 20
        let half: CGFloat = 0.5
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        roundLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Screen.height / 5)
            make.centerX.equalToSuperview().offset(half)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(roundLabel.snp.bottom).offset(padding)
            make.centerX.equalToSuperview().offset(half)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(view.snp.width).multipliedBy(1.2) // Assuming 1.2 aspect ratio
        }
        
        vsImageView.snp.makeConstraints { make in
            make.centerX.equalTo(collectionView.snp.centerX)
            make.centerY.equalTo(collectionView.snp.centerY).offset(-padding * 1.5)
            make.width.equalTo(25)
            make.height.equalTo(25)
        }
    }
    
    private func addDataLabels(_ currentItem: User) -> [String] {
        var dataLabelTexts: [String] = []
        
        if let height = currentItem.subInfo?.height {
            dataLabelTexts.append("\(height)")
        }
        
        if let job = currentItem.subInfo?.job {
            dataLabelTexts.append("\(job)")
        }
        
        dataLabelTexts.append("\(currentItem.location.address)")
        return dataLabelTexts
    }
}

