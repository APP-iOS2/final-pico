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
 like OR disLike 됐는지 판단 해 버튼 모양 다르게 -> 판단은 어떻게? [🔥]  DB로 판단?
 자동 높이 조절
 
 */

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
    //
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
        stackView.spacing = 10
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
    
    @objc func tappedNavigationButton() {
        self.present(actionSheetController, animated: true)
    }
    
    // 버튼 클릭시 액션 (Like, DisLike)
    private func buttonAction() {
        likeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                UIView.animate(withDuration: 0.5, animations: {
                    self.likeButton.transform = CGAffineTransform(translationX: 0, y: 100)
                    self.disLikeButton.transform = CGAffineTransform(translationX: 0, y: 100)
                    self.showToast(message: "\(self.user.nickName) Like!")
                    self.viewModel.saveLikeData(receiveUserInfo: self.user, likeType: .like)
                    //                    self.likeButton.isHidden = true
                    //                    self.disLikeButton.isHidden = true
                })
            })
            .disposed(by: disposeBag)
        
        disLikeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                UIView.animate(withDuration: 0.5, animations: {
                    self.likeButton.transform = CGAffineTransform(translationX: 0, y: 100)
                    self.disLikeButton.transform = CGAffineTransform(translationX: 0, y: 100)
                    self.showAlert(message: "한소희 DisLike!.", yesAction: nil)
                    self.viewModel.saveLikeData(receiveUserInfo: self.user, likeType: .dislike)
                    //                    self.likeButton.isHidden = true
                    //                    self.disLikeButton.isHidden = true
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
                self.basicInformationViewContoller.config(mbti: user.mbti, nameAgeText: "\(user.nickName),  \(user.age)", locationText: "\(user.location.address)", heightText: "\(1756)")
                guard let subInfo = user.subInfo else { return }
                self.configSubInfoView()
                self.aboutMeViewController.config(intro: subInfo.intro ?? "", eduText: "\(subInfo.education)", religionText: "\(subInfo.religion)", smokeText: "\(subInfo.smokeStatus)", jobText: "\(subInfo.job)", drinkText: "\(subInfo.drinkStatus)")
                self.subInfomationViewController.config(hobbies: subInfo.hobbies ?? [], personalities: subInfo.personalities ?? [], likeMbtis: subInfo.favoriteMBTIs ?? [])
            }, onCompleted: {
                Loading.hideLoading()
            })
            .disposed(by: disposeBag)
    }
    
    // 네비게이션 바 설정
    private func configureNavigationBar() {
        let rightBarButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(tappedNavigationButton))
        self.navigationItem.rightBarButtonItem = rightBarButton
        self.navigationController?.navigationBar.tintColor = .black
    }
    
    // 바 버튼 아이템 클릭시 액션시트
    private func configActionSheet() {
        // 신고 버튼 클릭 시 다음 액션 시트로 이동
        let actionReport = UIAlertAction(title: "신고", style: .default) { _ in
            self.showingReportSheet()
        }
        
        // 차단 버튼 클릭 시 ShowAlert
        let actionBlock = UIAlertAction(title: "차단", style: .default) { _ in
            self.showAlert(message: "차단 하시겠습니까?", title: "차단하기", isCancelButton: true) {
                self.viewModel.blockUser(block: Block(blockedId: "12066FD9-5F5E-4F62-9F7B-FFF1113E8FCD", blockedDate: Date().timeIntervalSince1970)) {
                    self.showAlert(message: "차단 완료", yesAction: nil)
                }
            }
        }
        
        let actionDrink = UIAlertAction(title: "취한거같아요", style: .destructive) { _  in
            self.showToast(message: "취했어요")
        }
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
    
    // DB에 신고 내용 저장
    private func reportAction(reason: String) {
        self.viewModel.reportUser(report: Report(reportedId: "\(self.user.id)", reason: reason, reportedDate: Date().timeIntervalSince1970)) {
            self.showAlert(message: "신고완료", yesAction: nil)
        }
    }
}

// MARK: - UI Associated Code
extension UserDetailViewController {
    // subInfo가 있을 시 뷰에 추가
    private func configSubInfoView() {
        verticalStackView.addArrangedSubview(aboutMeViewController.view)
        verticalStackView.addArrangedSubview(subInfomationViewController.view)
        subInfomationViewController.view.snp.makeConstraints { make in
            make.height.equalTo(Screen.height * 0.7)
        }
        aboutMeViewController.view.snp.makeConstraints { make in
            make.height.equalTo(Screen.height * 0.35)
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
        [scrollView, disLikeButton, likeButton].forEach { view.addSubview($0) }
        scrollView.addSubview(verticalStackView)
        scrollView.addSubview(userImageViewController.view)
        [basicInformationViewContoller.view]
            .forEach { verticalStackView.addArrangedSubview($0) }
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
        }
    }
    // Made In GPT 수정할게용,,
    private func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textAlignment = .center
        toastLabel.textColor = .white
        toastLabel.backgroundColor = UIColor.orange // You can choose any background color
        toastLabel.layer.cornerRadius = toastLabel.bounds.size.height / 2
        toastLabel.clipsToBounds = true
        toastLabel.font = UIFont.systemFont(ofSize: 16)
        toastLabel.numberOfLines = 0
        
        toastLabel.alpha = 0
        view.addSubview(toastLabel)
        
        toastLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            toastLabel.alpha = 1
            toastLabel.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            toastLabel.backgroundColor = UIColor.green // Change to a different color
            self.view.layoutIfNeeded()
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 2.0, animations: {
                toastLabel.alpha = 0
                toastLabel.transform = .identity
                toastLabel.backgroundColor = UIColor.orange // Revert to the original color
                self.view.layoutIfNeeded()
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
}
