//
//  SignUpPictureViewController.swift
//  Pico
//
//  Created by LJh on 2023/09/27.
//
import UIKit
import SnapKit
import PhotosUI
import AVFoundation
import Vision
import Photos

final class SignUpPictureViewController: UIViewController {
    let viewModel: SignUpViewModel
    
    init(viewModel: SignUpViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let pictureManager: PictureService = PictureService()
    private var isDetectedImage: Bool? = false
    private var objectDetectionRequest: VNCoreMLRequest?
    private var userImages: [UIImage] = []
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = .picoGray
        view.progressTintColor = .picoBlue
        view.layer.cornerRadius = SignView.progressViewCornerRadius
        view.layer.masksToBounds = true
        view.progress = viewModel.progressStatus
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
        label.accessibilityHint = "라벨 밑에 사진을 고르는 버튼이 있습니다."
        return label
    }()
    
    private let nextButton: UIButton = {
        let button = CommonButton(type: .custom)
        button.setTitle("다음", for: .normal)
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
        view.register(cell: SignUpPictureEditCollectionCell.self)
        return view
    }()
    
    // MARK: - LifeCyle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.configBackgroundColor(color: .systemBackground)        
        configNavigationBackButton()
        addSubViews()
        makeConstraints()
        configButton()
        configCollectionView()
        pictureManager.requestPhotoLibraryAccess(in: self)
    }
    override func viewDidAppear(_ animated: Bool) {
        viewModel.animateProgressBar(progressView: progressView, endPoint: 6)
    }
    // MARK: - Config
    private func configButton() {
        nextButton.addTarget(self, action: #selector(tappedNextButton), for: .touchUpInside)
    }
    
    private func configCollectionView() {
        collectionView.configBackgroundColor()
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func configNextButton(isEnabled: Bool) {
        nextButton.isEnabled = isEnabled
        nextButton.backgroundColor = isEnabled ? .picoBlue : .picoGray
    }
    
    // MARK: - Tapped
    @objc private func tappedNextButton(_ sender: UIButton) {
        Loading.showLoading(title: "AI가 얼굴인식 중이에요!\n잠시만 기다려주세요! (최대 1분 소요)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            let yoloManager: YoloService = YoloService()
            yoloManager.loadYOLOv3Model()
            
            let detectionGroup = DispatchGroup()
            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                
                var allImagesDetected = true
                
                for image in userImages {
                    detectionGroup.enter()
                    
                    yoloManager.detectPeople(image: image) {
                        detectionGroup.leave()
                    }
                    
                    if !(yoloManager.isDetectedImage ?? true) {
                        allImagesDetected = false
                    }
                }
                
                detectionGroup.notify(queue: .main) { [weak self] in
                    guard let self = self else { return }
                    
                    Loading.hideLoading()
                    if allImagesDetected {
                        showCustomAlert(alertType: .onlyConfirm, titleText: "알림", messageText: "사진이 등록되었습니다.", confirmButtonText: "확인", comfrimAction: { [weak self] in
                            guard let self = self else { return }
                            
                            viewModel.imageArray = self.userImages
                            let viewController = SignUpTermsOfServiceViewController(viewModel: self.viewModel)
                            navigationController?.pushViewController(viewController, animated: true)
                        })
                    } else {
                        showCustomAlert(alertType: .onlyConfirm, titleText: "알림", messageText: "사진 등록에 실패하였습니다.\n얼굴이 잘 나온 사진을 등록해 주세요.", confirmButtonText: "확인", comfrimAction: { [weak self] in
                            guard let self = self else { return }
                            
                            userImages.removeAll()
                            collectionView.reloadData()
                            configNextButton(isEnabled: false)
                        })
                    }
                }
            }
        }
    }
}

// MARK: - 사진 관련
extension SignUpPictureViewController: PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc private func openPhotoLibrary() {
        
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 3 // 최대 선택 가능한 이미지 수
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        } else {
            pictureManager.unauthorized(in: self)
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        var selectedImages: [UIImage] = []
        
        for result in results where result.itemProvider.canLoadObject(ofClass: UIImage.self) {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, _ ) in
                guard let self = self else { return }
                
                guard let image = image as? UIImage else { return }
                selectedImages.append(image)
                
                guard selectedImages.count == results.count else { return }
                userImages = selectedImages
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    collectionView.reloadData()
                    configNextButton(isEnabled: true)
                }
            }
        }
    }
}

// MARK: - 컬렉션 관련
extension SignUpPictureViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userImages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath, cellType: SignUpPictureEditCollectionCell.self)
        cell.configure(imageName: "chu", isHidden: true)
        cell.cellConfigure()
        if indexPath.row == 0 {
            cell.configure(imageName: "chu", isHidden: false)
        }
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
        for viewItem in [progressView, notifyLabel, subNotifyLabel, nextButton, collectionView] {
            view.addSubview(viewItem)
        }
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(SignView.progressViewTopPadding)
            make.leading.equalTo(SignView.padding)
            make.trailing.equalTo(-SignView.padding)
            make.height.equalTo(8)
        }
        
        notifyLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(SignView.padding)
            make.leading.equalTo(SignView.padding)
            make.trailing.equalTo(-SignView.padding)
        }
        
        subNotifyLabel.snp.makeConstraints { make in
            make.top.equalTo(notifyLabel.snp.bottom).offset(SignView.subPadding)
            make.leading.equalTo(notifyLabel.snp.leading)
            make.trailing.equalTo(notifyLabel.snp.trailing)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(subNotifyLabel.snp.bottom).offset(SignView.contentPadding)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(155)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.equalTo(notifyLabel.snp.leading)
            make.trailing.equalTo(notifyLabel.snp.trailing)
            make.bottom.equalTo(safeArea).offset(SignView.bottomPadding)
            make.height.equalTo(CommonConstraints.buttonHeight)
        }
    }
}
