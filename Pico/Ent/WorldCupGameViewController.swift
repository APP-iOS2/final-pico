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
    
    private var worldCupViewModel = WorldCupViewModel()
    private let disposeBag = DisposeBag()
    private var users = BehaviorRelay<[User]>(value: [])
    private var semifinals: [User] = []
    private var finals: [User] = []
    private var winner: [User] = []
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
        label.text = "마음에 드는 친구를 선택하세요!"
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
    
    private let startNewRoundButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.picoButtonFont
        button.backgroundColor = .picoBlue
        button.layer.cornerRadius = 10
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.configBackgroundColor()
        addViews()
        makeConstraints()
        configCollectionView()
        configUserData()
        configStartNewRoundButton()
        worldCupViewModel.playBackgroundMusic()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        worldCupViewModel.stopBackgroundMusic()
    }
    
    private func configCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(WorldCupCollectionViewCell.self, forCellWithReuseIdentifier: "WorldCupCollectionViewCell")
        collectionView.backgroundColor = .clear
        collectionView.layer.cornerRadius = 5
        addShadow()
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumInteritemSpacing = 20
        }
    }
    
    private func configUserData() {
        worldCupViewModel.users
            .map { $0.prefix(8).map { $0 } }
            .subscribe(onNext: { [weak self] fetchedUsers in
                self?.users.accept(Array(fetchedUsers))
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    private func addShadow(opacity: Float = 0.07, radius: CGFloat = 5.0) {
        collectionView.layer.masksToBounds = false
        collectionView.layer.shadowColor = UIColor.black.cgColor
        collectionView.layer.shadowOffset = CGSize(width: 10, height: 10)
        collectionView.layer.shadowOpacity = opacity
        collectionView.layer.shadowRadius = radius
    }
    
    private func showResultViewController(with user: User) {
        let resultViewController = WorldCupResultViewController()
        resultViewController.selectedItem = user
        navigationController?.pushViewController(resultViewController, animated: true)
    }
    
    private func addViews() {
        [backgroundImageView, roundLabel, contentLabel, collectionView, vsImageView, startNewRoundButton].forEach { item in
            view.addSubview(item)
        }
    }
    
    private func cellClickAction(indexPath: IndexPath) {
        worldCupViewModel.selectedIndexPath = indexPath
        worldCupViewModel.animateSelectedCell(collectionView: collectionView, indexPath: indexPath, completion: {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                
                if self.index == 8 || self.index == 12 {
                    self.changeRoundLabel(withText: self.index == 8 ? "4강" : "결승")
                }
                
                if self.index == 14 {
                    let selectedItem = self.winner[0]
                    self.showResultViewController(with: selectedItem)
                }
            }
        })
    }

    private func configStartNewRoundButton() {
        startNewRoundButton.isHidden = true
        startNewRoundButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.collectionView.isHidden = false
                self?.vsImageView.isHidden = false
                self?.startNewRoundButton.isHidden = true
                self?.animateToNextRound()
            })
            .disposed(by: disposeBag)
    }
    
    private func animateStartNewRoundButton() {
        startNewRoundButton.isHidden = false
        UIView.transition(with: startNewRoundButton, duration: 1.5, options: .transitionCrossDissolve, animations: {
            self.startNewRoundButton.transform = .identity
        })
    }
    
    private func animateToNextRound() {
        DispatchQueue.main.async {
            let transition = CATransition()
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromRight
            transition.duration = 0.5
            
            self.collectionView.layer.add(transition, forKey: nil)
            self.collectionView.reloadData()
            
            self.vsImageView.layer.add(transition, forKey: nil)
            self.vsImageView.isHidden = false
        }
    }

    private func changeRoundLabel(withText text: String) {
        roundLabel.text = text
        startNewRoundButton.setTitle(text == "4강" ? "4강 시작" : "결승 시작", for: .normal)
        animateStartNewRoundButton()
        collectionView.isHidden = true
        vsImageView.isHidden = true
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
            make.height.equalTo(view.snp.width).multipliedBy(1.2)
        }
        
        vsImageView.snp.makeConstraints { make in
            make.centerX.equalTo(collectionView.snp.centerX)
            make.centerY.equalTo(collectionView.snp.centerY).offset(-padding * 1.5)
            make.width.equalTo(25)
            make.height.equalTo(25)
        }
        
        startNewRoundButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
    }
    
    private func detectCapture() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(captureAction),
            name: UIScreen.capturedDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func captureAction() {
        if UIScreen.main.isCaptured {
            view.secureMode(enable: true)
        } else {
            view.secureMode(enable: false)
        }
    }
}

extension WorldCupGameViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.value.count / 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WorldCupCollectionViewCell", for: indexPath) as? WorldCupCollectionViewCell else { return UICollectionViewCell() }
        
        let round: Int
        let currentUser: User
        
        switch index {
        case 0..<8:
            round = 8
            currentUser = users.value[index + indexPath.item]
            worldCupViewModel.configure(cell: cell, with: currentUser)
            self.roundLabel.text = "\(round)강"
        case 8..<12:
            round = 4
            currentUser = semifinals[index - 8 + indexPath.item]
            worldCupViewModel.configure(cell: cell, with: currentUser)
        case 12:
            round = 2
            currentUser = finals[index - 12 + indexPath.item]
            worldCupViewModel.configure(cell: cell, with: currentUser)
        default:
            round = 0
            currentUser = winner[0]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 10
        let collectionViewWidth = collectionView.frame.width
        let itemWidth = (collectionViewWidth - (padding * 2)) / 2
        
        return CGSize(width: itemWidth, height: Screen.height * 2 / 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch index {
        case 0..<6:
            let selectedItem = users.value[index + indexPath.item]
            semifinals.append(selectedItem)
            index += 2
            cellClickAction(indexPath: indexPath)
        case 6..<8:
            let selectedItem = users.value[index + indexPath.item]
            semifinals.append(selectedItem)
            index += 2
            cellClickAction(indexPath: indexPath)
        case 8..<10:
            let selectedItem = semifinals[index - 8 + indexPath.item]
            finals.append(selectedItem)
            index += 2
            cellClickAction(indexPath: indexPath)
        case 10..<12:
            let selectedItem = semifinals[index - 8 + indexPath.item]
            finals.append(selectedItem)
            index += 2
            cellClickAction(indexPath: indexPath)
        default:
            let selectedItem = finals[index - 12 + indexPath.item]
            winner.append(selectedItem)
            index += 2
            cellClickAction(indexPath: indexPath)
        }
    }
}
