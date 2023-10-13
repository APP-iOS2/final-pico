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
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        let image = UIImage(systemName: "xmark", withConfiguration: imageConfig)
        let button = UIButton()
        button.layer.masksToBounds = false
        button.layer.cornerRadius = 15
        button.backgroundColor = .picoGray
        button.setImage(image, for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .picoTitleFont
        label.textColor = .picoFontBlack
        return label
    }()
    
    private let completeButton: UIButton = {
        let button = UIButton()
        button.setTitle("완료", for: .normal)
        button.layer.masksToBounds = false
        button.layer.cornerRadius = 15
        button.backgroundColor = .picoBlue
        return button
    }()
    
    private let collectionViewFlowLayout = CenterAlignedCollectionViewFlowLayout()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewFlowLayout)
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.delegate = self
        view.register(ProfileEditModalCollectionCell.self, forCellWithReuseIdentifier: "ProfileEditModalCollectionCell")
        return view
    }()
    
     let profileEditModalViewModel = ProfileEditModalViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addViews()
        makeConstraints()
        binds()
    }
    
    private func binds() {
        backButton.rx.tap
            .bind {
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        completeButton.rx.tap
            .bind {
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        profileEditModalViewModel.name
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)

        profileEditModalViewModel.data
            .bind(to: collectionView.rx.items(cellIdentifier: "ProfileEditModalCollectionCell", cellType: ProfileEditModalCollectionCell.self)) { _, model, cell in
                
                cell.cellConfigure()
                cell.configure(content: model)
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { index in
              
                    print("\(index.row)")
                })
            .disposed(by: disposeBag)
    }
    
    private func addViews() {
        view.addSubview([backButton, titleLabel, collectionView, completeButton])
    }
    
    private func makeConstraints() {
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-15)
            make.width.height.equalTo(30)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(100)
        }
        
        completeButton.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(25)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(40)
        }
    }
    
}

extension ProfileEditCollectionModalViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var data = [String]()
        _ = profileEditModalViewModel.data.subscribe(onNext: {
            data = $0
        })
        return ProfileEditModalCollectionCell.fittingSize(height: 30, text: data[indexPath.item])
    }
}
