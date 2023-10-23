//
//  ProfileEditViewController.swift
//  Pico
//
//  Created by 김민기 on 2023/09/27.
//

import UIKit
import SnapKit
import RxSwift
import RxDataSources
import PhotosUI

final class ProfileEditViewController: UIViewController {
    
    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.register(cell: ProfileEditImageTableCell.self)
        view.register(cell: ProfileEditNicknameTabelCell.self)
        view.register(cell: ProfileEditLoactionTabelCell.self)
        view.register(cell: ProfileEditTextTabelCell.self)
        view.configBackgroundColor()
        view.showsVerticalScrollIndicator = false
        view.separatorStyle = .none
        return view
    }()
    
    private let refreshControl = UIRefreshControl()
    private let disposeBag = DisposeBag()
    weak var profileEditImageDelegate: ProfileEditImageDelegate?
    weak var profileEditNicknameDelegate: ProfileEditNicknameDelegate?
    private let pictureManager = PictureManager()
    private var userImages: [UIImage] = []
    private let profileViewModel: ProfileViewModel
    private lazy var profileEditViewModel = ProfileEditViewModel(profileViewModel: self.profileViewModel)
    
    init(profileViewModel: ProfileViewModel) {
        self.profileViewModel = profileViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        makeConstraints()
        binds()
        configView()
        configTableView()
        delegateConfig()
        configRefresh()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func delegateConfig() {
        profileEditImageDelegate = self
        profileEditNicknameDelegate = self
    }
    
    private func binds() {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel> { _, tableView, indexPath, item in
            switch item {
            case .profileEditImageTableCell(let images):
                let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: ProfileEditImageTableCell.self)
                cell.config(images: images, viewModel: self.profileEditViewModel)
                cell.profileEditImageDelegate = self.profileEditImageDelegate
                return cell
                
            case .profileEditNicknameTabelCell:
                let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: ProfileEditNicknameTabelCell.self)
                cell.profileEditNicknameDelegate = self.profileEditNicknameDelegate
                cell.selectionStyle = .none
                return cell
                
            case .profileEditLoactionTabelCell(let location):
                let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: ProfileEditLoactionTabelCell.self)
                cell.selectionStyle = .none
                cell.configure(location: location, viewModel: self.profileEditViewModel)
                return cell
                
            case .profileEditTextTabelCell(let title, let content):
                let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: ProfileEditTextTabelCell.self)
                cell.configure(titleLabel: title, contentLabel: content)
                return cell
            }
        }
        
        profileEditViewModel.sectionsRelay
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    private func configView() {
        title = "프로필 수정"
        view.configBackgroundColor()
    }
    
    private func configTableView() {
        tableView.delegate = self
    }
    
    private func configRefresh() {
        refreshControl.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        refreshControl.tintColor = .picoBlue
        tableView.refreshControl = refreshControl
    }
    
    private func addViews() {
        view.addSubview([tableView])
    }
    
    private func makeConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func presentModalView(viewController: UIViewController, viewHeight: CGFloat) {
        let modalViewController = viewController
        if let sheet = modalViewController.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            if #available(iOS 16.0, *) {
                sheet.detents = [ .custom { _ in
                    return viewHeight } ]
            } else { sheet.detents = [.medium()] }
        }
        modalViewController.modalPresentationStyle = .formSheet
        present(modalViewController, animated: true)
    }
    
    @objc private func refreshTable(refresh: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            profileEditViewModel.loadUserData()
            refresh.endRefreshing()
        }
    }
    
}

extension ProfileEditViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 155
        case 1, 2:
            return 45
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0...1:
            let view = UIView()
            return view
        case 2:
            let view = ProfileEditTableHeaderView()
            return view
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch section {
        case 2: 
            let view = UIView()
            return view
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            return 5
        case 2:
            return 20
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 2:
            return 20
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            break
        case 1:
            break
        case 2:
            switch indexPath.row {
            case 0:
                profileEditViewModel.modalName.accept(ProfileEditViewModel.SubInfoCase.intro.name)
                profileEditViewModel.modalType = .intro
                profileEditViewModel.textData = profileEditViewModel.userData?.subInfo?.intro
                presentModalView(viewController: ProfileEditTextModalViewController(profileEditViewModel: profileEditViewModel), viewHeight: 180)
            case 1:
                profileEditViewModel.modalName.accept(ProfileEditViewModel.SubInfoCase.height.name)
                profileEditViewModel.modalType = .height
                profileEditViewModel.textData = String(profileEditViewModel.userData?.subInfo?.height ?? 0)
                presentModalView(viewController: ProfileEditPickerViewController(profileEditViewModel: profileEditViewModel), viewHeight: 230)
                
            case 2:
                profileEditViewModel.modalName.accept(ProfileEditViewModel.SubInfoCase.job.name)
                profileEditViewModel.modalType = .job
                profileEditViewModel.textData = profileEditViewModel.userData?.subInfo?.job
                presentModalView(viewController: ProfileEditTextModalViewController(profileEditViewModel: profileEditViewModel), viewHeight: 180)
                
            case 3:
                profileEditViewModel.modalName.accept(ProfileEditViewModel.SubInfoCase.religion.name)
                profileEditViewModel.modalType = .religion
                profileEditViewModel.modalCollectionData = profileEditViewModel.religionType
                profileEditViewModel.selectedIndex = profileEditViewModel.findIndex(for: profileEditViewModel.userData?.subInfo?.religion?.rawValue ?? "", in: ReligionType.allCases.map({ $0.rawValue})) ?? nil
                presentModalView(viewController: ProfileEditCollectionModalViewController(profileEditViewModel: profileEditViewModel, collectionHeight: 110), viewHeight: 250)
                
            case 4:
                profileEditViewModel.modalName.accept(ProfileEditViewModel.SubInfoCase.drink.name)
                profileEditViewModel.modalType = .drink
                profileEditViewModel.modalCollectionData = profileEditViewModel.frequencyType
                profileEditViewModel.selectedIndex = profileEditViewModel.findIndex(for: profileEditViewModel.userData?.subInfo?.drinkStatus?.rawValue ?? "", in: FrequencyType.allCases.map({ $0.rawValue})) ?? nil
                
                presentModalView(viewController: ProfileEditCollectionModalViewController(profileEditViewModel: profileEditViewModel, collectionHeight: 40), viewHeight: 180)
                
            case 5:
                profileEditViewModel.modalName.accept(ProfileEditViewModel.SubInfoCase.smoke.name)
                profileEditViewModel.modalType = .smoke
                profileEditViewModel.modalCollectionData = profileEditViewModel.frequencyType
                profileEditViewModel.selectedIndex = profileEditViewModel.findIndex(for: profileEditViewModel.userData?.subInfo?.smokeStatus?.rawValue ?? "", in: FrequencyType.allCases.map({ $0.rawValue})) ?? nil
                
                presentModalView(viewController: ProfileEditCollectionModalViewController(profileEditViewModel: profileEditViewModel, collectionHeight: 40), viewHeight: 180)
                
            case 6:
                profileEditViewModel.modalName.accept(ProfileEditViewModel.SubInfoCase.education.name)
                profileEditViewModel.modalType = .education
                profileEditViewModel.modalCollectionData = profileEditViewModel.educationType
                profileEditViewModel.selectedIndex = profileEditViewModel.findIndex(for: profileEditViewModel.userData?.subInfo?.education?.rawValue ?? "", in: EducationType.allCases.map({ $0.rawValue})) ?? nil
                
                presentModalView(viewController: ProfileEditCollectionModalViewController(profileEditViewModel: profileEditViewModel, collectionHeight: 70), viewHeight: 210)
                
            case 7:
                profileEditViewModel.modalName.accept(ProfileEditViewModel.SubInfoCase.personalities.name)
                profileEditViewModel.modalType = .personalities
                profileEditViewModel.collectionData = profileEditViewModel.userData?.subInfo?.personalities
                presentModalView(viewController: ProfileEditCollTextModalViewController(profileEditViewModel: profileEditViewModel), viewHeight: 230)
                
            case 8:
                profileEditViewModel.modalName.accept(ProfileEditViewModel.SubInfoCase.hobbies.name)
                profileEditViewModel.modalType = .hobbies
                profileEditViewModel.collectionData = profileEditViewModel.userData?.subInfo?.hobbies
                
                presentModalView(viewController: ProfileEditCollTextModalViewController(profileEditViewModel: profileEditViewModel), viewHeight: 230)
            case 9:
                profileEditViewModel.modalName.accept(ProfileEditViewModel.SubInfoCase.favoriteMBTIs.name)
                profileEditViewModel.modalType = .favoriteMBTIs
                profileEditViewModel.selectedIndexs = profileEditViewModel.findMbtiIndex(for: profileEditViewModel.userData?.subInfo?.favoriteMBTIs?.map({ $0.rawValue }) ?? [], in: MBTIType.allCases.map { $0.rawValue })
                profileEditViewModel.modalCollectionData = MBTIType.allCases.map { $0.nameString }
                presentModalView(viewController: ProfileEditCollectionModalViewController(profileEditViewModel: profileEditViewModel, collectionHeight: 150), viewHeight: 290)
            default:
                break
            }
        default: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ProfileEditViewController: ProfileEditImageDelegate {
    func presentCustomAlert(messageText: String) {
        showCustomAlert(alertType: .onlyConfirm, titleText: "알림", messageText: messageText, confirmButtonText: "확인")
    }
    
    func presentPickerView() {
        pictureManager.requestPhotoLibraryAccess(in: self)
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            var configuration = PHPickerConfiguration()
            if let count = profileEditViewModel.collectionData?.count {
                configuration.selectionLimit = 3 - count
            }
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        } else {
            pictureManager.unauthorized(in: self)
        }
    }
}

extension ProfileEditViewController: ProfileEditNicknameDelegate {
    func presentEditView() {
        guard profileEditViewModel.compareChuCount() else {
            showCustomAlert(alertType: .onlyConfirm, titleText: "알림", messageText: "현재 보유 중인 츄의 개수가 부족합니다.", confirmButtonText: "확인")
            return
        }
        profileEditViewModel.modalName.accept(ProfileEditViewModel.SubInfoCase.nickName.name)
        profileEditViewModel.modalType = .nickName
        profileEditViewModel.textData = profileEditViewModel.userData?.nickName
        presentModalView(viewController: ProfileEditNicknameModalViewController(profileEditViewModel: profileEditViewModel), viewHeight: 190)
    }
}

extension ProfileEditViewController {
    func detectionYolo() {
        let yoloManager: YoloManager = YoloManager()
        yoloManager.loadYOLOv3Model()
        
        let detectionGroup = DispatchGroup()
        
        SignLoadingManager.showLoading(text: "사진을 평가중이에요!")
        DispatchQueue.global().async {
            var allImagesDetected = true
            
            for image in self.userImages {
                detectionGroup.enter()
                
                yoloManager.detectPeople(image: image) {
                    detectionGroup.leave()
                }
                
                if !(yoloManager.isDetectedImage ?? true) {
                    allImagesDetected = false
                }
            }
            if allImagesDetected {
                self.profileEditViewModel.userImages = self.userImages
                self.profileEditViewModel.saveImage()
            }
            detectionGroup.notify(queue: .main) {
                SignLoadingManager.hideLoading()
                if allImagesDetected {
                    self.showCustomAlert(alertType: .onlyConfirm, titleText: "알림", messageText: "사진이 등록되었습니다.", confirmButtonText: "확인")
                } else {
                    self.showCustomAlert(alertType: .onlyConfirm, titleText: "알림", messageText: "사진 등록에 실패하였습니다.\n얼굴이 잘 나온 사진을 등록해 주세요.", confirmButtonText: "확인", comfrimAction: {
                        self.userImages.removeAll()
                    })
                }
            }
        }
    }
}

extension ProfileEditViewController: PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        var selectedImages: [UIImage] = []
        
        for result in results where result.itemProvider.canLoadObject(ofClass: UIImage.self) {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self ](image, _ ) in
                
                guard let image = image as? UIImage else { return }
                selectedImages.append(image)
                guard selectedImages.count == results.count else { return }
                self?.userImages = selectedImages
                self?.detectionYolo()
            }
        }
    }
}
