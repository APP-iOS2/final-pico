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
    
    var removedView: [UIView] = []
    var userCards: [User] = []
    var users = BehaviorRelay<[User]>(value: [])
    var myLikes = BehaviorRelay<[Like.LikeInfo]>(value: [])

    lazy var likeLabel: UILabel = createLabel(text: "GOOD", setColor: .systemGreen)
    lazy var passLabel: UILabel = createLabel(text: "PASS", setColor: .systemBlue)
    
    private let numberOfCards: Int = 4
    private let emptyView = HomeEmptyView()
    private let disposeBag = DisposeBag()
    private let viewModel = HomeViewModel()
    private let loadingView = LoadingAnimationView()
    private let homeGuideView = HomeGuideView()
    private let loginUser = UserDefaultsManager.shared.getUserData()
    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavigationBarItem()
        configButtons()
        bind()
        loadCards()
    }
    
    private func bind() {
        viewModel.otherUsers
            .bind(to: users)
            .disposed(by: disposeBag)
        viewModel.myLikes
            .bind(to: myLikes)
            .disposed(by: disposeBag)
    }
    
    private func addSubView() {
        view.addSubview([likeLabel, passLabel])
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
        Observable.combineLatest(users, myLikes, viewModel.myBlockUsersId)
            .map { [self] users, myLikes, myBlockUsersId in
                print("내가 평가한 유저: \(myLikes.count)명")
                let myLikedUserIds = Set(myLikes.map { $0.likedUserId })
                let myMbti = Set(mbti.map { $0.rawValue })
                let blocksId = Set(myBlockUsersId.map { $0.userId })
                return users.filter { user in
                    var maxAge: Int = HomeViewModel.filterAgeMax
                    var maxDistance: Int = HomeViewModel.filterDistance
//                    print(blocksId.count)
                    if HomeViewModel.filterAgeMax == 61 {
                        maxAge = 100
                    }
                    if HomeViewModel.filterDistance == 501 {
                        maxDistance = 10000
                    }
                    let filterAge = (HomeViewModel.filterAgeMin..<maxAge + 1).contains(user.age)
                    let distance = viewModel.calculateDistance(user: user)
                    let filterDistance = (0..<maxDistance + 1).contains(Int(distance / 1000))
                    return !myLikedUserIds.contains(user.id) && myMbti.contains(user.mbti.rawValue) && filterAge && filterDistance && !blocksId.contains(loginUser.userId)
                }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (filteredUsers: [User]) in
                guard let self = self else { return }
                print("필터후 유저: \(filteredUsers.count)명")
                userCards = filteredUsers
                view.subviews.forEach { subView in
                  subView.removeFromSuperview()
               }
                addLoadingView()
                addUserCards()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.addEmptyView()
                    self.loadingView.removeFromSuperview()
                }
                addSubView()
                addGuideView()
                makeConstraints()
            }, onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
    
    private func addLoadingView() {
        loadingView.frame = view.frame
        loadingView.backgroundColor = .systemBackground
        loadingView.animate()
        view.addSubview(loadingView)
    }
    
    private func addEmptyView() {
        view.insertSubview(emptyView, at: 0)
        emptyView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
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
        emptyView.reLoadButton.addTarget(self, action: #selector(reloadView), for: .touchUpInside)
    }
    
    private func configNavigationBarItem() {
        let filterImage = UIImage(systemName: "slider.horizontal.3")
        let filterButton = UIBarButtonItem(image: filterImage, style: .plain, target: self, action: #selector(tappedFilterButton))
        filterButton.tintColor = .darkGray
        
        let notificationImage = UIImage(systemName: "bell.fill")
        let notificationButton = UIBarButtonItem(image: notificationImage, style: .plain, target: self, action: #selector(tappedNotificationButton))
        notificationButton.tintColor = .darkGray
        
        navigationItem.rightBarButtonItems = [filterButton, notificationButton]
    }
    
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
    
    @objc func reloadView() {
        let newViewController = HomeViewController()
        self.navigationController?.setViewControllers([newViewController], animated: false)
        HomeUserCardViewModel.passedMyData.removeAll()
        HomeUserCardViewModel.passedUserData.removeAll()
    }
    
    @objc func tappedFilterButton() {
        let viewController = HomeFilterViewController()
        viewController.homeViewController = self
        addChild(viewController)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func tappedNotificationButton() {
        let viewController = NotificationViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}
