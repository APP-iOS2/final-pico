//
//  ProfileEditCollectionModalViewController.swift
//  Pico
//
//  Created by 김민기 on 2023/10/13.
//

import UIKit
import SnapKit
import RxSwift

/*음주, 흡연, 종교, 교육 */
final class ProfileEditCollectionModalViewController: UIViewController {
    
    private let backButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        let image = UIImage(systemName: "xmark", withConfiguration: imageConfig)
        let button = UIButton()
        button.layer.masksToBounds = false
        button.layer.cornerRadius = 12
        button.backgroundColor = .picoGray
        button.setImage(image, for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .picoSubTitleFont
        label.textColor = .picoFontBlack
        return label
    }()
    
    private let completeButton: UIButton = {
        let button = UIButton()
        button.setTitle("완료", for: .normal)
        button.layer.masksToBounds = false
        button.layer.cornerRadius = 15
        button.backgroundColor = .picoGray
        button.isEnabled = false
        return button
    }()
    
    private let collectionViewFlowLayout = CenterAlignedCollectionViewFlowLayout()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewFlowLayout)
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.delegate = self
        view.dataSource = self
        view.register(cell: ProfileEditModalCollectionCell.self)
        view.register(cell: ProfileEditModalMbtiCell.self)
        return view
    }()
    
    let profileEditViewModel: ProfileEditViewModel
    private let disposeBag = DisposeBag()
    
    private var selectedData = ""
    
    init(profileEditViewModel: ProfileEditViewModel) {
        self.profileEditViewModel = profileEditViewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addViews()
        makeConstraints()
        binds()
        colleciotionConfigure()
    }
    
    private func binds() {
        backButton.rx.tap
            .bind { [weak self] _ in
                guard let self else { return }
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        completeButton.rx.tap
            .bind { [weak self] _ in
                guard let self else { return }
                self.profileEditViewModel.updateData(data: self.selectedData)
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        profileEditViewModel.modalName
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func colleciotionConfigure() {
        if profileEditViewModel.modalType == .favoriteMBTIs {
            collectionView.allowsMultipleSelection = true
        } else {
            collectionView.allowsMultipleSelection = false
        }
    }
    private func addViews() {
        view.addSubview([backButton, titleLabel, collectionView, completeButton])
    }
    
    private func makeConstraints() {
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-15)
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(300)
        }

        completeButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-30)
        }
    }
    
}

extension ProfileEditCollectionModalViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profileEditViewModel.modalCollectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let label = UILabel()
        let text = profileEditViewModel.modalCollectionData[indexPath.item]
        label.text = text
        label.sizeToFit()
        let size = label.frame.size
        
        if profileEditViewModel.modalType == .favoriteMBTIs {
            return CGSize(width: 70, height: 30)
        } else {
            return CGSize(width: size.width + 30, height: 30)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch profileEditViewModel.modalType {
           
        case .favoriteMBTIs:
            let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath, cellType: ProfileEditModalMbtiCell.self)
            cell.configure(content: profileEditViewModel.modalCollectionData[indexPath.row])
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath, cellType: ProfileEditModalCollectionCell.self)
            cell.configure(content: profileEditViewModel.modalCollectionData[indexPath.row])
            guard let selectedIndex = profileEditViewModel.selectedIndex else { return cell }
            if indexPath.row == selectedIndex {
                cell.isSelected = true
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedIndex = profileEditViewModel.selectedIndex else {
            completeButton.isEnabled = true
            completeButton.backgroundColor = .picoBlue
            changeModalType(index: indexPath.row)
            return
        }
        
        if indexPath.row != selectedIndex {
            completeButton.isEnabled = true
            completeButton.backgroundColor = .picoBlue
            changeModalType(index: indexPath.row)
        } else {
            completeButton.isEnabled = false
            completeButton.backgroundColor = .picoGray
        }
        print(indexPath.row)
    }
    
    func changeModalType(index: Int) {
        switch profileEditViewModel.modalType {
        case .religion:
            selectedData = ReligionType.allCases.map({ $0.rawValue})[index]
        case .drink, .smoke:
            selectedData = FrequencyType.allCases.map({ $0.rawValue})[index]
        case .education:
            selectedData = EducationType.allCases.map({ $0.rawValue})[index]
        default:
            break
        }
    }
}
