//
//  DetailViewController.swift
//  Pico
//
//  Created by 신희권 on 2023/09/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import CoreLocation
//

final class UserDetailViewController: UIViewController {
    // 이전 뷰에서 실행이 필요 해 Defalut로 작성
    var viewModel: UserDetailViewModel!
    private let disposeBag = DisposeBag()
    private var distance = CLLocationDistance()
    // SubViews
    private let userImageViewController = UserImageViewController()
    private let basicInformationViewContoller = BasicInformationViewContoller()
//    private let introViewController = IntroViewController()
//    private let aboutMeViewController = AboutMeViewController()
//    private let subInfomationViewController = SubInfomationViewController()
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 5
        return stackView
    }()
    
    private var disLikeButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 35, weight: .regular)
        let image = UIImage(systemName: "hand.thumbsdown.fill", withConfiguration: imageConfig)
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .picoBlue.withAlphaComponent(0.8)
        button.frame = CGRect(x: 0, y: 0, width: 65, height: 65)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.isHidden = true
        return button
    }()
    
    private var likeButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 35, weight: .regular)
        let image = UIImage(systemName: "hand.thumbsup.fill", withConfiguration: imageConfig)
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .picoBlue.withAlphaComponent(0.8)
        button.frame = CGRect(x: 0, y: 0, width: 65, height: 65)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.isHidden = true
        return button
    }()
    
    private let actionSheetController = UIAlertController()
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        Loading.showLoading()
        view.configBackgroundColor()
        addChilds()
        addViews()
        bind()
        makeConstraints()
        configureNavigationBar()
        configActionSheet()
        configButtonHidden()
        buttonAction()
        Loading.hideLoading()
        tabBarController?.tabBar.isHidden = true
    }
    
    // MARK: - objc
    @objc func tappedNavigationButton() {
        self.present(actionSheetController, animated: true)
    }
    
    // MARK: - RxSwift
    // 버튼 클릭시 액션 (Like, DisLike)
    private func buttonAction() {
        likeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.saveLikeData(receiveUserInfo: self.viewModel.user, likeType: .like)
                let viewController = HomeViewController()
                self.navigationController?.pushViewController(viewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        disLikeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                 self.viewModel.saveLikeData(receiveUserInfo: self.viewModel.user, likeType: .dislike)
                let viewController = HomeViewController()
                self.navigationController?.pushViewController(viewController, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    // Bind Code
    private func bind() {
        self.navigationItem.title = "\(viewModel.user.nickName),  \(viewModel.user.age)"
        self.userImageViewController.config(images: viewModel.user.imageURLs)
        // SubInfo 있을 시
        if let subInfo = viewModel.user.subInfo {
            // Height가 없을시 nil 전달
            if subInfo.height == nil {
                self.basicInformationViewContoller.config(mbti: viewModel.user.mbti,
                                                          nameAgeText: "\(viewModel.user.nickName),  \(viewModel.user.age)",
                                                          locationText: "\(viewModel.user.location.address)",
                                                          heightText: nil)
            }
            distance = viewModel.calculateDistance()
            self.basicInformationViewContoller.config(mbti: viewModel.user.mbti,
                                                      nameAgeText: "\(viewModel.user.nickName),  \(viewModel.user.age)",
                                                      locationText: "\(viewModel.user.location.address), \(String(format: "%.2f", distance / 1000))km",
                                                      heightText: String(subInfo.height ?? 0))
            
            self.introViewController.config(intro: subInfo.intro)
            
            self.aboutMeViewController.config(eduText: subInfo.education?.name,
                                              religionText: subInfo.religion?.name,
                                              smokeText: subInfo.smokeStatus?.name,
                                              jobText: subInfo.job,
                                              drinkText: subInfo.drinkStatus?.name
            )
            
            self.subInfomationViewController.config(hobbies: subInfo.hobbies,
                                                    personalities: subInfo.personalities,
                                                    likeMbtis: subInfo.favoriteMBTIs)
            // SubInfo가 없을시 뷰에 안보이도록 설정
        } else {
            self.basicInformationViewContoller.config(mbti: viewModel.user.mbti,
                                                      nameAgeText: "\(viewModel.user.nickName),  \(viewModel.user.age)",
                                                      locationText: "\(viewModel.user.location.address)",
                                                      heightText: nil)
            [self.aboutMeViewController.view, self.introViewController.view, self.subInfomationViewController.view].forEach {
                self.verticalStackView.removeArrangedSubview($0)
                $0.isHidden = true
            }
        }
    }
    
    // Pass Good Label
    private func createLabel(text: String, setColor: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 40)
        label.textColor = setColor.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.layer.borderWidth = 4
        label.layer.borderColor = setColor.withAlphaComponent(0.8).cgColor
        label.layer.cornerRadius = 5
        label.alpha = 0
        return label
    }
    
    // MARK: - ButtonHidden Config
    private func configButtonHidden() {
        viewModel.isLike {
            self.likeButton.isHidden = $0
            self.disLikeButton.isHidden = $0
        }
    }
    
    // MARK: - NavigaionBar Config
    private func configureNavigationBar() {
        let rightBarButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(tappedNavigationButton))
        self.navigationItem.rightBarButtonItem = rightBarButton
        self.navigationController?.navigationBar.tintColor = .black
    }
    
    // MARK: - RightBarButtonItem Cofing
    // 바 버튼 아이템 클릭시 액션시트
    private func configActionSheet() {
        // 신고 버튼 클릭 시 다음 액션 시트로 이동
        let actionReport = UIAlertAction(title: "신고", style: .default) { _ in
            self.showingReportSheet()
        }
        
        // 차단 버튼 클릭 시 ShowAlert
        let actionBlock = UIAlertAction(title: "차단", style: .default) { _ in
            self.showCustomAlert(alertType: .canCancel, titleText: "차단하기", messageText: "\(self.viewModel.user.nickName)님을 차단 하시겠습니까?", confirmButtonText: "차단", comfrimAction: {
                self.viewModel.blockUser(blockedUser: self.viewModel.user) {
                    self.showCustomAlert(alertType: .onlyConfirm, titleText: "차단", messageText: "\(self.viewModel.user.nickName)님 차단 완료", confirmButtonText: "확인", comfrimAction: {
                        HomeFilterViewController.filterChangeState = true
                        let viewController = HomeViewController()
                        self.navigationController?.pushViewController(viewController, animated: true)
                    })
                }
            })
        }
        let actionCancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        [actionReport, actionBlock, actionCancel].forEach { actionSheetController.addAction($0) }
    }
    
    // 신고 버튼 클릭시 액션시트
    private func showingReportSheet() {
        let nextActionSheet = UIAlertController(title: "신고 사유", message: "신고 사유를 클릭 해 주세요", preferredStyle: .actionSheet)
        let actionImage = UIAlertAction(title: "불쾌한 사진", style: .default) { _ in
            self.showCustomAlert(alertType: .canCancel, titleText: "\(self.viewModel.user.nickName)님을 신고 하시겠습니까?", messageText: "신고된 유저는 관리자의 검토 후 제제처리됩니다.", confirmButtonText: "신고", comfrimAction: {
                self.reportAction(reason: "불쾌한 사진")
            })
        }
        
        let actionFact = UIAlertAction(title: "허위 프로필", style: .default) { _ in
            self.showCustomAlert(alertType: .canCancel, titleText: "\(self.viewModel.user.nickName)님을 신고 하시겠습니까?", messageText: "신고된 유저는 관리자의 검토 후 제제처리됩니다.", confirmButtonText: "신고", comfrimAction: {
                self.reportAction(reason: "허위 프로필")
            })
        }
        
        let actionTheft = UIAlertAction(title: "사진 도용", style: .default) { _ in
            self.showCustomAlert(alertType: .canCancel, titleText: "\(self.viewModel.user.nickName)님을 신고 하시겠습니까?", messageText: "신고된 유저는 관리자의 검토 후 제제처리됩니다.", confirmButtonText: "신고", comfrimAction: {
                self.reportAction(reason: "사진 도용")
            })
        }
        
        let actionAbuse = UIAlertAction(title: "욕설 및 비방", style: .default) { _ in
            self.showCustomAlert(alertType: .canCancel, titleText: "\(self.viewModel.user.nickName)님을 신고 하시겠습니까?", messageText: "신고된 유저는 관리자의 검토 후 제제처리됩니다.", confirmButtonText: "신고", comfrimAction: {
                self.reportAction(reason: "욕설 및 비방")
            })
        }
        
        let actionCancel = UIAlertAction(title: "취소", style: .cancel)
        [actionImage, actionFact, actionTheft, actionAbuse, actionCancel].forEach { nextActionSheet.addAction($0) }
        self.present(nextActionSheet, animated: true)
    }
    
    // DB에 신고 내용 저장
    private func reportAction(reason: String) {
        self.viewModel.reportUser(reportedUser: viewModel.user, reason: reason) {
            self.showCustomAlert(alertType: .onlyConfirm, titleText: "신고", messageText: "\(self.viewModel.user.nickName)님 신고 완료", confirmButtonText: "확인", comfrimAction: nil)
        }
    }
}

// MARK: - UI Associated Code
extension UserDetailViewController {
    // subInfo가 있을 시 뷰에 추가
    private func addChilds() {
        [userImageViewController, basicInformationViewContoller, introViewController, aboutMeViewController, subInfomationViewController].forEach {
            // 이거 왜 쓰는 거지..
            addChild($0)
            $0.didMove(toParent: self)
        }
    }
    
    private func addViews() {
        view.addSubview([scrollView, disLikeButton, likeButton])
        scrollView.addSubview([userImageViewController.view, verticalStackView])
        verticalStackView.addArrangedSubview(basicInformationViewContoller.view)
        
//        [basicInformationViewContoller.view, introViewController.view, aboutMeViewController.view, subInfomationViewController.view].forEach {
//            verticalStackView.addArrangedSubview($0)
//        }
    }
    
    private func makeConstraints() {
        likeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-60)
            make.width.height.equalTo(65)
        }
        
        disLikeButton.snp.makeConstraints { make in
            make.trailing.equalTo(likeButton.snp.leading).offset(-15)
            make.bottom.equalTo(likeButton)
            make.width.height.equalTo(65)
        }
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        userImageViewController.view.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        verticalStackView.snp.makeConstraints { make in
            make.top.equalTo(userImageViewController.view.snp.bottom).offset(20)
            make.leading.trailing.bottom.width.equalToSuperview().inset(20)
        }
    }
}
