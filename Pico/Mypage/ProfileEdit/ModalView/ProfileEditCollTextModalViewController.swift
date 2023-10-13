//
//  ProfileEditCollectionTextModalViewController.swift
//  Pico
//
//  Created by 김민기 on 2023/10/13.
//

import UIKit
import SnapKit
import RxSwift
/*취미, 인트로, 의사*/
final class ProfileEditCollTextModalViewController: UIViewController {
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
        label.text = "종교"
        return label
    }()
    
    private let textField = CommonTextField()
    
    private let completeButton: UIButton = {
        let button = UIButton()
        button.setTitle("완료", for: .normal)
        button.layer.masksToBounds = false
        button.layer.cornerRadius = 15
        button.backgroundColor = .picoBlue
        return button
    }()
    
    private let collectionViewFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 18
        layout.minimumInteritemSpacing = 10
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewFlowLayout)
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.delegate = self
        view.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        view.register(ProfileEditTextModalCollectionCell.self, forCellWithReuseIdentifier: "ProfileEditTextModalCollectionCell")
        return view
    }()
    
    private let profileEditModalViewModel = ProfileEditModalViewModel()
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
        
        profileEditModalViewModel.data
            .bind(to: collectionView.rx.items(cellIdentifier: "ProfileEditTextModalCollectionCell", cellType: ProfileEditTextModalCollectionCell.self)) { _, model, cell in
                
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
        view.addSubview([backButton, titleLabel, collectionView, textField, completeButton])
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
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(50)
        }
        completeButton.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(25)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(40)
        }
    }
    
}

extension ProfileEditCollTextModalViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        
        var data = [String]()
        _ = profileEditModalViewModel.data.subscribe(onNext: {
            data = $0
        })
        let text = data[indexPath.row]
        label.text = text
        label.sizeToFit()
        let size = label.frame.size
        return CGSize(width: size.width + 35, height: 30)
    }
}
