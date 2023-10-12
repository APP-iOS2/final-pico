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
/* TODOs:
 like Btn 클릭시 -> like 목록으로 이동, 버튼 Hide
 like OR disLike 됐는지 판단 해 버튼 모양 다르게 -> 판단은 어떻게?
 like 했을 때 dismiss 하고 LIKE U DB로
 디테일 뷰 서브인포 로드
 신고 시 DB입력
 차단 시 안보이게
 
 */
final class UserDetailViewController: UIViewController {
    var viewModel = UserDetailViewModel(user: User.userData)
    // private var user: User
    private let disposeBag = DisposeBag()
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
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 10
        return stackView
    }()
    
    //    private lazy var disLikeButton: UIButton = {
    //        let imageConfig = UIImage.SymbolConfiguration(pointSize: 35, weight: .regular)
    //        let image = UIImage(systemName: "hand.thumbsdown.fill", withConfiguration: imageConfig)
    //        let button = UIButton()
    //        button.setImage(image, for: .normal)
    //        button.tintColor = .white
    //        button.backgroundColor = .picoBlue.withAlphaComponent(0.8)
    //        button.frame = CGRect(x: 0, y: 0, width: 65, height: 65)
    //        button.layer.cornerRadius = 0.5 * button.bounds.size.width
    //        return button
    //    }()
    //
    //    private lazy var likeButton: UIButton = {
    //        let imageConfig = UIImage.SymbolConfiguration(pointSize: 35, weight: .regular)
    //        let image = UIImage(systemName: "hand.thumbsup.fill", withConfiguration: imageConfig)
    //        let button = UIButton()
    //        button.setImage(image, for: .normal)
    //        button.tintColor = .white
    //        button.backgroundColor = .picoBlue.withAlphaComponent(0.8)
    //        button.frame = CGRect(x: 0, y: 0, width: 65, height: 65)
    //        button.layer.cornerRadius = 0.5 * button.bounds.size.width
    //        return button
    //    }()
    
    private let actionSheetController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        addChilds()
        addViews()
        makeConstraints()
        configureNavigationBar()
        configActionSheet()
        buttonSelector()
        bind()
    }
    
    @objc func tappedNavigationButton() {
        self.present(actionSheetController, animated: true)
    }
    
    @objc private func buttonAction() {
        print("")
    }
    
    private func bind() {
        viewModel.userObservable
            .subscribe(onNext: { user in
                guard let subInfo = user.subInfo else { return }
                self.configSubInfoView()
                self.navigationItem.title = "\(user.nickName),  \(user.age)"
                self.userImageViewController.config(images: user.imageURLs)
                self.basicInformationViewContoller.config(mbti: user.mbti, nameAgeText: "\(user.nickName),  \(user.age)", locationText: "\(user.location.address)", heightText: "\(subInfo.height)")
                self.aboutMeViewController.config(intro: subInfo.intro, eduText: "\(subInfo.education)", religionText: "\(subInfo.religion)", smokeText: "\(subInfo.smokeStatus)", jobText: "\(subInfo.job)", drinkText: "\(subInfo.drinkStatus)")
                self.subInfomationViewController.config(hobbies: subInfo.hobbies, personalities: subInfo.personalities, likeMbtis: subInfo.favoriteMBTIs)
            }, onCompleted: {
                Loading.hideLoading()
            })
            .disposed(by: disposeBag)
    }
    
    private func buttonSelector() {
        //        likeButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        //        disLikeButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }
    
    // 네비게이션 바 설정
    private func configureNavigationBar() {
        let rightBarButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(tappedNavigationButton))
        self.navigationItem.rightBarButtonItem = rightBarButton
        self.navigationController?.navigationBar.tintColor = .black
    }
    
    // Right바 버튼 아이템 클릭시 액션시트
    private func configActionSheet() {
        // 신고 버튼 클릭 시 다음 액션 시트로 이동
        let actionReport = UIAlertAction(title: "신고", style: .default) { _ in
            self.showingReportSheet()
        }
        
        let actionBlock = UIAlertAction(title: "차단", style: .default) { _ in
            self.showAlert(message: "차단 하시겠습니까?", title: "차단하기", isCancelButton: true) {
                self.viewModel.blockUser(block: Block(blockedId: "12066FD9-5F5E-4F62-9F7B-FFF1113E8FCD", blockedDate: 0.1)) {
                    self.showAlert(message: "차단 완료", yesAction: nil)
                }
            }
        }
        
        let actionDrink = UIAlertAction(title: "취한거같아요", style: .destructive, handler: nil)
        let actionCancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        [actionReport, actionBlock, actionDrink, actionCancel].forEach { actionSheetController.addAction($0) }
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
    
    private func reportAction(reason: String) {
        self.viewModel.reportUser(report: Report(reportedId: "user", reason: reason, reportedDate: 1.0)) {
            self.showAlert(message: "신고완료", yesAction: nil)
        }
    }
    
    // subInfo가 있을 시 뷰에 추가
    private func configSubInfoView() {
        verticalStackView.addArrangedSubview(subInfomationViewController.view)
        subInfomationViewController.view.snp.makeConstraints { make in
            make.height.equalTo(Screen.height * 0.7)
        }
    }
    
    private func addChilds() {
        [userImageViewController, basicInformationViewContoller, aboutMeViewController, subInfomationViewController].forEach {
            // 이거 왜 쓰는 거지..
            addChild($0)
            $0.didMove(toParent: self)
        }
    }
    
    private func addViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(verticalStackView)
        [userImageViewController.view, basicInformationViewContoller.view, aboutMeViewController.view]
            .forEach { verticalStackView.addArrangedSubview($0) }
    }
    
    private func makeConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        verticalStackView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }
        
        userImageViewController.view.snp.makeConstraints { make in
            make.height.equalTo(Screen.height * 0.6)
        }
        
        basicInformationViewContoller.view.snp.makeConstraints { make in
            make.height.equalTo(Screen.height * 0.2)
        }
        
        aboutMeViewController.view.snp.makeConstraints { make in
            make.height.equalTo(Screen.height * 0.35)
        }
        
    }
}
