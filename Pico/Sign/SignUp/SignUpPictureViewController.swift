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

final class SignUpPictureViewController: UIViewController {
    
    private var isDetectedImage: Bool? = false
    private var objectDetectionRequest: VNCoreMLRequest?
    private var userImages: [UIImage] = []
    let viewModel: SignUpViewModel = .shared

    private let progressView: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = .picoBetaBlue
        view.progressTintColor = .picoBlue
        view.progress = 0.142 * 6
        view.layer.cornerRadius = SignView.progressViewCornerRadius
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
        view.register(cell: ProfileEditCollectionCell.self)
        return view
    }()

    // MARK: - LifeCyle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.configBackgroundColor()
        configNavigationBackButton()
        addSubViews()
        makeConstraints()
        configCollectionView()
        loadYOLOv3Model()
    }
    
    // MARK: - Config
    private func configCollectionView() {
        collectionView.configBackgroundColor()
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func configNextButton(isEnabled: Bool) {
        if isEnabled {
            nextButton.isEnabled = isEnabled
            nextButton.backgroundColor = .picoBlue
        } else {
            nextButton.isEnabled = isEnabled
            nextButton.backgroundColor = .picoGray
        }
    }
    
    // MARK: - Tapped
    @objc private func tappedNextButton(_ sender: UIButton) {

        let detectionGroup = DispatchGroup()
        
        Loading.showLoading()
        DispatchQueue.global().async {
            var allImagesDetected = true

            for image in self.userImages {
                detectionGroup.enter()
                
                self.detectPeople(image: image) {
                    detectionGroup.leave()
                }
                
                if !(self.isDetectedImage ?? true) {
                    allImagesDetected = false
                }
            }
            
            detectionGroup.notify(queue: .main) {
                Loading.hideLoading()
                
                if allImagesDetected {
                    self.showAlert(message: "이미지가 등록되었습니다.") {
                        self.viewModel.imageArray = self.userImages
                        let viewController = SignUpTermsOfServiceViewController()
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                } else {
                    self.showAlert(message: "이미지 등록에 실패하셨습니다.") {
                        self.userImages.removeAll()
                        self.collectionView.reloadData()
                        self.configNextButton(isEnabled: false)
                    }
                }
            }
        }
    }
}

// MARK: - 사진 관련
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
                
                guard let image = image as? UIImage else { return }
                selectedImages.append(image)
                
                guard selectedImages.count == results.count else { return }
                self.userImages = selectedImages
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.configNextButton(isEnabled: true)
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
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath, cellType: ProfileEditCollectionCell.self)
        
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

// MARK: - YOLOv3Model 관련
extension SignUpPictureViewController {
    
    private func loadYOLOv3Model() {
        let configuration = MLModelConfiguration()
        guard let yoloModel = try? VNCoreMLModel(for: YOLOv3(configuration: configuration).model) else {
            fatalError("Failed to load YOLOv3 model.")
        }

        objectDetectionRequest = VNCoreMLRequest(model: yoloModel, completionHandler: { [weak self] request, error in
            self?.isDetectedImage = self?.handleObjectDetectionResults(request: request, error: error)
        })
    }
    
    private func handleObjectDetectionResults(request: VNRequest, error: Error?) -> Bool {
        guard let results = request.results as? [VNRecognizedObjectObservation] else { return false }

        var detectedObjects = ""
        for result in results {
            if let label = result.labels.first {
                if label.identifier == "person" {
                    detectedObjects += "\(label.identifier) (\(String(format: "%.2f", label.confidence * 100))%)\n"
                    if label.confidence * 100 >= 80 {
                        print(label.confidence)
                        return true
                    }
                }
            }
        }
        return false
    }
    
    private func detectPeople(image: UIImage, completion: @escaping () -> ()) {
        guard let cgImage = image.cgImage, let objectDetectionRequest = objectDetectionRequest else { return }

        let request = VNCoreMLRequest(model: objectDetectionRequest.model) { [weak self] request, error in
            self?.isDetectedImage = self?.handleObjectDetectionResults(request: request, error: error)
            completion()
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform object detection: \(error)")
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
