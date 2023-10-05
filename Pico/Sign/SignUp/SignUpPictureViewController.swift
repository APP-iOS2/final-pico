//
//  SignUpPictureViewController.swift
//  Pico
//
//  Created by LJh on 2023/09/27.
//

import UIKit
import SnapKit
import PhotosUI
import Firebase
import FirebaseCore
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift

final class SignUpPictureViewController: UIViewController {
    
    private var userImages: [UIImage] = []
    private let storageRef = Storage.storage().reference()
    
    private let progressView: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = .picoBetaBlue
        view.progressTintColor = .picoBlue
        view.progress = 0.142 * 6
        view.layer.cornerRadius = Constraint.SignView.progressViewCornerRadius
        view.layer.masksToBounds = true
        return view
    }()
    
    private let notifyLabel: UILabel = {
        let label = UILabel()
        label.text = "사진을 등록해주세요"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.picoTitleFont
        return label
    }()
    
    private let subNotifyLabel: UILabel = {
        let label = UILabel()
        label.text = "주위의 친구들에게 보여줄 사진을 골라보아요 😀 (최대 3장)"
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.textColor = .picoFontGray
        label.font = UIFont.picoDescriptionFont
        return label
    }()
    
    private lazy var nextButton: UIButton = {
        let button = CommonButton(type: .custom)
        button.setTitle("다음", for: .normal)
        button.addTarget(self, action: #selector(tappedNextButton), for: .touchUpInside)
        button.isEnabled = false
        button.backgroundColor = .picoGray
        return button
    }()
    
    private let collectionViewFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 14
        layout.minimumInteritemSpacing = 0
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewFlowLayout)
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.contentInset = .zero
        view.backgroundColor = .clear
        view.contentInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
        view.register(ProfileEditCollectionCell.self, forCellWithReuseIdentifier: Identifier.CollectionView.profileEditCollectionCell)
        return view
    }()
    
    // MARK: - LifeCyle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addSubViews()
        makeConstraints()
        configBackButton()
        configCollectionView()
    }
    
    // MARK: - Config
    private func configCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    // MARK: - Tapped
    @objc private func tappedNextButton(_ sender: UIButton) async {
        print(userImages)
        let viewController = SignUpTermsOfServiceViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

// MARK: - 사진 받아오는곳
extension SignUpPictureViewController: PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc private func openPhotoLibrary() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 3 // 최대 선택 가능한 이미지 수
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        var selectedImages: [UIImage] = []
        
        for result in results where result.itemProvider.canLoadObject(ofClass: UIImage.self) {
            result.itemProvider.loadObject(ofClass: UIImage.self) { (image, _ ) in
                if let image = image as? UIImage {
                    selectedImages.append(image)
                    
                    if selectedImages.count == results.count {
                        self.userImages = selectedImages
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                            if !self.userImages.isEmpty {
                                self.nextButton.isEnabled = true
                                self.nextButton.backgroundColor = .picoBlue
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 컬렉션
extension SignUpPictureViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userImages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.CollectionView.profileEditCollectionCell, for: indexPath) as? ProfileEditCollectionCell else { return UICollectionViewCell() }
        
        cell.configure(imageName: "chu")
        cell.backgroundColor = .lightGray
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 10
        if indexPath.row != 0 {
            cell.configure(image: userImages[indexPath.row - 1])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth: CGFloat = 120
        let cellHeight = collectionView.bounds.height
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            openPhotoLibrary()
        }
    }
}
// MARK: - UI 관련
extension SignUpPictureViewController {
  
    private func addSubViews() {
        for viewItem in [progressView, notifyLabel, subNotifyLabel, nextButton, collectionView] { // imageStackView를 포함하여 모든 뷰를 추가
            view.addSubview(viewItem)
        }
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(Constraint.SignView.progressViewTopPadding)
            make.leading.equalTo(Constraint.SignView.padding)
            make.trailing.equalTo(-Constraint.SignView.padding)
            make.height.equalTo(8)
        }
        
        notifyLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(Constraint.SignView.padding)
            make.leading.equalTo(Constraint.SignView.padding)
            make.trailing.equalTo(-Constraint.SignView.padding)
        }
        
        subNotifyLabel.snp.makeConstraints { make in
            make.top.equalTo(notifyLabel.snp.bottom).offset(Constraint.SignView.subPadding)
            make.leading.equalTo(notifyLabel.snp.leading)
            make.trailing.equalTo(notifyLabel.snp.trailing)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(subNotifyLabel.snp.bottom).offset(Constraint.SignView.contentPadding)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(155)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.equalTo(notifyLabel.snp.leading)
            make.trailing.equalTo(notifyLabel.snp.trailing)
            make.bottom.equalTo(safeArea).offset(Constraint.SignView.bottomPadding)
            make.height.equalTo(Constraint.Button.commonHeight)
        }
    }
}
