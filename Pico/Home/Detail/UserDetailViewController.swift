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

final class UserDetailViewController: UIViewController {
    // 이전 뷰에서 실행이 필요 해 Defalut로 작성
    var viewModel: UserDetailViewModel!
    private var user: User!
    private let disposeBag = DisposeBag()
    /// SubViews
    private let userImageViewController = UserImageViewControll()
    private let basicInformationViewContoller = BasicInformationViewContoller()
    private let aboutMeViewController = AboutMeViewController()
    private let subInfomationViewController = SubInfomationViewController()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        return stackView
    }()
    
    private lazy var disLikeButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 35, weight: .regular)
        let image = UIImage(systemName: "hand.thumbsdown.fill", withConfiguration: imageConfig)
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .picoBlue.withAlphaComponent(0.8)
        button.frame = CGRect(x: 0, y: 0, width: 65, height: 65)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        return button
    }()
    
    private lazy var likeButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 35, weight: .regular)
        let image = UIImage(systemName: "hand.thumbsup.fill", withConfiguration: imageConfig)
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .picoBlue.withAlphaComponent(0.8)
        button.frame = CGRect(x: 0, y: 0, width: 65, height: 65)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        return button
    }()
    
    private let actionSheetController = UIAlertController()
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        Loading.showLoading()
        view.backgroundColor = .systemBackground
        tabBarController?.tabBar.isHidden = true
        addChilds()
        addViews()
        makeConstraints()
        configureNavigationBar()
        configActionSheet()
        buttonAction()
        bind()
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
                UIView.animate(withDuration: 0.5, animations: {
                    self.likeButton.transform = CGAffineTransform(translationX: 0, y: 100)
                    self.disLikeButton.transform = CGAffineTransform(translationX: 0, y: 100)
                    self.showCustomAlert(alertType: .onlyConfirm, titleText: "Like", messageText: "\(self.user.nickName)님 Like", confirmButtonText: "확인", comfrimAction: nil)
                    self.viewModel.saveLikeData(receiveUserInfo: self.user, likeType: .like)
                })
            })
            .disposed(by: disposeBag)
        
        disLikeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                UIView.animate(withDuration: 0.5, animations: {
                    self.likeButton.transform = CGAffineTransform(translationX: 0, y: 100)
                    self.disLikeButton.transform = CGAffineTransform(translationX: 0, y: 100)
                    self.showCustomAlert(alertType: .onlyConfirm, titleText: "Like", messageText: "\(self.user.nickName)님 DisLike", confirmButtonText: "확인", comfrimAction: nil)
                    self.viewModel.saveLikeData(receiveUserInfo: self.user, likeType: .dislike)
                })
            })
            .disposed(by: disposeBag)
    }
    
    // Bind Code
    private func bind() {
        viewModel.userObservable
            .subscribe(onNext: { user in
                self.user = user
                self.navigationItem.title = "\(user.nickName),  \(user.age)"
                self.userImageViewController.config(images: user.imageURLs)
                // SubInfo 있을 시
                if let subInfo = user.subInfo {
                    // Height가 없을시 nil 전달
                    if subInfo.height == nil {
                        self.basicInformationViewContoller.config(mbti: user.mbti,
                                                                  nameAgeText: "\(user.nickName),  \(user.age)",
                                                                  locationText: "\(user.location.address)",
                                                                  heightText: nil)
                    }
                    self.basicInformationViewContoller.config(mbti: user.mbti,
                                                              nameAgeText: "\(user.nickName),  \(user.age)",
                                                              locationText: "\(user.location.address)",
                                                              heightText: String(subInfo.height ?? 0))
                    
                    self.aboutMeViewController.config(intro: subInfo.intro,
                                                      eduText: subInfo.education?.name,
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
                    self.basicInformationViewContoller.config(mbti: user.mbti,
                                                              nameAgeText: "\(user.nickName),  \(user.age)",
                                                              locationText: "\(user.location.address)",
                                                              heightText: nil)
                    [self.aboutMeViewController.view, self.subInfomationViewController.view].forEach {
//                        self.verticalStackView.removeArrangedSubview($0)
                        $0.isHidden = true
                    }
                }
            }, onCompleted: {
                Loading.hideLoading()
            })
            .disposed(by: disposeBag)
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
            self.showAlert(message: "차단 하시겠습니까?", title: "차단하기", isCancelButton: true) {
                self.viewModel.blockUser(blockedUser: self.user) {
                    self.showCustomAlert(alertType: .onlyConfirm, titleText: "차단", messageText: "\(self.user.nickName)님 차단 완료", confirmButtonText: "확인", comfrimAction: nil)
                }
            }
        }
        let actionCancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        [actionReport, actionBlock, actionCancel].forEach { actionSheetController.addAction($0) }
    }
    
    // 신고 버튼 클릭시 액션시트
    private func showingReportSheet() {
        let nextActionSheet = UIAlertController(title: "신고 사유", message: "신고 사유를 클릭 해 주세요", preferredStyle: .actionSheet)
        let actionImage = UIAlertAction(title: "이상한 사진", style: .default) { _ in
            self.showAlert(message: "이런 이유로 신고 하시겠습니까", title: "이상한 사진", isCancelButton: true) {
                self.reportAction(reason: "이상한 사진")
            }
        }
        
        let actionFact = UIAlertAction(title: "허위 사실", style: .default) { _ in
            self.showAlert(message: "이런 이유로 신고 하시겠습니까", title: "허위 사실", isCancelButton: true) {
                self.reportAction(reason: "허위 사실")
            }
        }
        
        let actionSexual = UIAlertAction(title: "성적인 내용", style: .default) { _ in
            self.showAlert(message: "이런 이유로 신고 하시겠습니까", title: "성적인 내용", isCancelButton: true) {
                self.reportAction(reason: "성적인 내용")
            }
        }
        
        let actionCancel = UIAlertAction(title: "취소", style: .cancel)
        [actionImage, actionFact, actionSexual, actionCancel].forEach { nextActionSheet.addAction($0) }
        self.present(nextActionSheet, animated: true)
    }
    
    // DB에 신고 내용 저장
    private func reportAction(reason: String) {
        self.viewModel.reportUser(reportedUser: user, reason: reason) {
            self.showCustomAlert(alertType: .onlyConfirm, titleText: "신고", messageText: "\(self.user.nickName)님 신고 완료", confirmButtonText: "확인", comfrimAction: nil)
        }
    }
}

// MARK: - UI Associated Code
extension UserDetailViewController {
    // subInfo가 있을 시 뷰에 추가
    private func addChilds() {
        [userImageViewController, basicInformationViewContoller, aboutMeViewController, subInfomationViewController].forEach {
            // 이거 왜 쓰는 거지..
            addChild($0)
            $0.didMove(toParent: self)
        }
    }
    
    private func addViews() {
        [scrollView, disLikeButton, likeButton].forEach { view.addSubview($0) }
        [userImageViewController.view, verticalStackView].forEach { scrollView.addSubview($0) }
        [basicInformationViewContoller.view, aboutMeViewController.view, subInfomationViewController.view].forEach {
            verticalStackView.addArrangedSubview($0)
        }
    }
    
    private func makeConstraints() {
        likeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-80)
        }
        
        disLikeButton.snp.makeConstraints { make in
            make.trailing.equalTo(likeButton.snp.leading).offset(-15)
            make.bottom.equalTo(likeButton)
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
        
        basicInformationViewContoller.view.snp.makeConstraints { make in
            make.height.equalTo(Screen.height * 0.2)
            //            make.top.leading.trailing.equalToSuperview()
        }
        
        subInfomationViewController.view.snp.makeConstraints { make in
            make.height.equalTo(Screen.height * 0.7)
        }
        
//        aboutMeViewController.view.snp.makeConstraints { make in
//            make.height.equalTo(Screen.height * 0.4)
//        }
        
    }
}
