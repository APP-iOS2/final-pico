//
//  ViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import CoreLocation

final class HomeViewController: BaseViewController {
    var isHomeVisible: Bool = false
    var doingReloadingHome: Bool = false
    var removedView: [UIView] = []
    var userCards: [User] = []
    var users = BehaviorRelay<[User]>(value: [])
    var myLikes = BehaviorRelay<[Like.LikeInfo]>(value: [])
    var likeLabel: UILabel = {
        let label = UILabel()
        label.text = "GOOD"
        label.font = .boldSystemFont(ofSize: 40)
        label.textColor = .systemGreen.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.layer.borderWidth = 4
        label.layer.borderColor = UIColor.systemGreen.withAlphaComponent(0.8).cgColor
        label.layer.cornerRadius = 5
        label.alpha = 0
        return label
    }()
    
    var passLabel: UILabel = {
        let label = UILabel()
        label.text = "PASS"
        label.font = .boldSystemFont(ofSize: 40)
        label.textColor = .systemBlue.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.layer.borderWidth = 4
        label.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.8).cgColor
        label.layer.cornerRadius = 5
        label.alpha = 0
        return label
    }()
    
    private let numberOfCards: Int = 4
    private let emptyView = HomeEmptyView()
    private let disposeBag = DisposeBag()
    private let viewModel = HomeViewModel()
    private let subViewModel = HomeUserCardViewModel()
    private let loadingView = LoadingAnimationView()
    private let homeGuideView = HomeGuideView()
    private let loginUser = UserDefaultsManager.shared.getUserData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavigationBarItem()
        configButtons()
        bind()
        loadCards()
        loadingView.homeAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isHomeVisible = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isHomeVisible = false
    }
    
    private func bind() {
        viewModel.users
            .bind(to: users)
            .disposed(by: disposeBag)
        viewModel.myLikes
            .bind(to: myLikes)
            .disposed(by: disposeBag)
    }
    
    private func addGuideView() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.last {
                let homeGuideView: HomeGuideView
                if let existedView = window.subviews.first(where: {
                    $0 is HomeGuideView
                }) as? HomeGuideView {
                    homeGuideView = existedView
                } else {
                    homeGuideView = HomeGuideView()
                    homeGuideView.frame = window.frame
                    if !UserDefaults.standard.bool(forKey: UserDefaultsManager.Key.dontWatchAgain.rawValue) {
                        window.addSubview(homeGuideView)
                    } else {
                        return
                    }
                }
            }
        }
    }
    
    private func loadCards() {
        var mbti: [MBTIType] = []
        if HomeViewModel.filterMbti.isEmpty {
            mbti = MBTIType.allCases
        } else {
            mbti = HomeViewModel.filterMbti
        }
        
        let combinedObservable = Observable.combineLatest(users, myLikes, viewModel.blocks)
        
        combinedObservable
            .flatMap { [weak self] users, myLikes, blocks -> Observable<[User]> in
                let myLikedUserIds = Set(myLikes.map { $0.likedUserId })
                let myMbti = Set(mbti.map { $0.rawValue })
                let myBlocks = Set(blocks.map { $0.userId })
                print("⎼⎼⎼⎼⎼⎼⎼HOME⎼⎼⎼⎼⎼⎼⎼⎼⎼")
                print(". 내가 평가한 유저: \(myLikes.count)명")
                print(". 내가 차단한 유저: \(blocks.count)명")
                
                let filteredUsers = users.filter { user in
                    var maxAge: Int = HomeViewModel.filterAgeMax
                    var maxDistance: Int = HomeViewModel.filterDistance
                    if HomeViewModel.filterAgeMax >= 61 {
                        maxAge = 100
                    }
                    if HomeViewModel.filterDistance == 501 {
                        maxDistance = 10000
                    }
                    let filterAge = (HomeViewModel.filterAgeMin..<maxAge + 1).contains(user.age)
                    let distance = self?.viewModel.calculateDistance(user: user) ?? 0.0
                    let filterDistance = (0..<maxDistance + 1).contains(Int(distance / 1000))
                    return !myLikedUserIds.contains(user.id) && myMbti.contains(user.mbti.rawValue) && filterAge && filterDistance && !myBlocks.contains(user.id)
                }
                return Observable.just(filteredUsers)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (filteredUsers: [User]) in
                guard let self = self else { return }
                print(". 필터후 유저: \(filteredUsers.count)명")
                print("⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺")
                userCards = filteredUsers
                view.subviews.forEach { subView in
                    subView.removeFromSuperview()
                }
                addUserCards()
                addLoadingView()
                addEmptyView()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) { [weak self] in
                    guard let self = self else { return }
                    loadingView.removeFromSuperview()
                    if view.subviews.count <= 3 {
                        goToFilterAlert()
                    }
                    doingReloadingHome = false
                }
                addSubView()
                addGuideView()
                makeConstraints()
            })
            .disposed(by: disposeBag)
    }

    func goToFilterAlert() {
        guard isHomeVisible else { return }
        viewModel.showHomeCustomAlert(
            alertType: .canCancel,
            titleText: "선호 설정으로 이동할까요?",
            messageText: "현재 설정으로 더 이상 찾을 수 있는 친구가 없어요.",
            cancelButtonText: "취소",
            confirmButtonText: "확인",
            comfrimAction: { [weak self] in
                guard let self = self else { return }
                let viewController = HomeFilterViewController()
                viewController.homeViewController = self
                viewController.hidesBottomBarWhenPushed = true
                addChild(viewController)
                navigationController?.pushViewController(viewController, animated: true)
            },
            viewController: self
        )
    }
    
    func addUserCards() {
        for userCard in userCards.prefix(self.numberOfCards) {
            var user = userCard
            user.imageURLs.insert(userCard.imageURLs[0], at: 1)
            let tabImageViewController = HomeUserCardViewController(user: user)
            tabImageViewController.homeViewController = self
            self.addChild(tabImageViewController)
            self.view.insertSubview(tabImageViewController.view, at: 1)
            userCards.removeFirst()
        }
    }
    
    private func addLoadingView() {
        loadingView.frame = view.frame
        loadingView.configBackgroundColor()
        view.addSubview(loadingView)
    }
    
    private func addEmptyView() {
        view.insertSubview(emptyView, at: 0)
        emptyView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func addSubView() {
        view.addSubview([likeLabel, passLabel])
    }
    
    private func makeConstraints() {
        likeLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.safeAreaLayoutGuide.snp.top).offset(70)
            make.width.equalTo(150)
        }
        
        passLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.safeAreaLayoutGuide.snp.top).offset(70)
            make.width.equalTo(150)
        }
    }
    
    private func configButtons() {
        emptyView.findNewFriendButton.addTarget(self, action: #selector(reloadView), for: .touchUpInside)
        emptyView.backUser.addTarget(self, action: #selector(tappedPickBackButton), for: .touchUpInside)
    }
    
    private func configNavigationBarItem() {
        let filterButton = UIButton(type: .custom)
        let filterImage = UIImage(systemName: "slider.horizontal.3")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 21))
        filterButton.setImage(filterImage, for: .normal)
        filterButton.frame.size = CGSize(width: 30, height: 30)
        filterButton.tintColor = .darkGray
        filterButton.addTarget(self, action: #selector(tappedFilterButton), for: .touchUpInside)
        filterButton.accessibilityLabel = "필터"
        
        let notificationButton = UIButton(type: .custom)
        let notificationImage = UIImage(systemName: "bell.fill")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 21))
        notificationButton.setImage(notificationImage, for: .normal)
        notificationButton.frame.size = CGSize(width: 30, height: 30)
        notificationButton.tintColor = .darkGray
        notificationButton.addTarget(self, action: #selector(tappedNotificationButton), for: .touchUpInside)
        notificationButton.accessibilityLabel = "알림"
        
        let filterBarButtonItem = UIBarButtonItem(customView: filterButton)
        let notificationBarButtonItem = UIBarButtonItem(customView: notificationButton)
        
        navigationItem.rightBarButtonItems = [filterBarButtonItem, notificationBarButtonItem]
    }
    
    private func detectCapture() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(captureAction),
            name: UIScreen.capturedDidChangeNotification,
            object: nil
        )
    }
  
    @objc func tappedPickBackButton() {
        if let lastView = removedView.last {
            showCustomAlert(
                alertType: .canCancel,
                titleText: "이전 평가로 돌아가시겠습니까?",
                messageText: "10 츄를 소모합니다. (현재 츄: \(UserDefaultsManager.shared.getChuCount()))",
                cancelButtonText: "취소",
                confirmButtonText: "확인",
                comfrimAction: { [weak self] in
                    guard let self = self else { return }
                    let remainingChu = UserDefaultsManager.shared.getChuCount()
                    if remainingChu >= 10 {
                        subViewModel.purchaseChu(currentChu: remainingChu, purchaseChu: 10)
                        subViewModel.deleteLikeData()
                        UIView.animate(withDuration: 0.3) {
                            lastView.center = self.view.center
                            lastView.transform = CGAffineTransform(rotationAngle: 0)
                        }
                        removedView.removeLast()
                    } else {
                        showCustomAlert(alertType: .canCancel, titleText: "보유 츄 부족", messageText: "보유하고 있는 츄가 부족합니다. \n현재 츄 : \(UserDefaultsManager.shared.getChuCount()) 개", cancelButtonText: "취소", confirmButtonText: "스토어로 이동", comfrimAction: {
                            let storeViewController = StoreViewController(viewModel: StoreViewModel())
                            self.navigationController?.pushViewController(storeViewController, animated: true)
                        })
                    }
                }
            )
        } else {
            showCustomAlert(alertType: .onlyConfirm, titleText: "이전 친구를 찾을 수 없습니다.", messageText: "💡 매칭된 상대는 되돌릴 수 없습니다.", confirmButtonText: "확인")
        }
    }
    
    @objc func reloadView() {
        let newViewController = HomeViewController()
        newViewController.doingReloadingHome = true
        self.navigationController?.setViewControllers([newViewController], animated: false)
        HomeUserCardViewModel.passedMyData.removeAll()
        HomeUserCardViewModel.passedUserData.removeAll()
    }
    
    @objc func tappedFilterButton() {
        let viewController = HomeFilterViewController()
        viewController.homeViewController = self
        viewController.hidesBottomBarWhenPushed = true
        addChild(viewController)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func tappedNotificationButton() {
        let viewController = NotificationViewController()
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func captureAction() {
        if UIScreen.main.isCaptured {
            view.secureMode(enable: true)
        } else {
            view.secureMode(enable: false)
        }
    }
}
