//
//  HomeTabImageViewController.swift
//  Pico
//
//  Created by 임대진 on 2023/09/25.
//

import UIKit
import SnapKit
import RxSwift
import CoreLocation

final class HomeUserCardViewController: UIViewController {
    
    weak var homeViewController: HomeViewController?
    private let user: User
    private let disposeBag = DisposeBag()
    private let viewModel = HomeUserCardViewModel()
    private let storeViewModel = StoreViewModel()
    private let currentUser = UserDefaultsManager.shared.getUserData()
    private var compatibilityView: CompatibilityView
    private var panGesture = UIPanGestureRecognizer()
    private var initialCenter = CGPoint()
    private var distance = CLLocationDistance()
    private var distanceLabel = UILabel()
    private var pageCount = 0
    
    init(user: User) {
        self.user = user
        compatibilityView = CompatibilityView(currentUser: currentUser, cardUser: user)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.pageIndicatorTintColor = UIColor.gray
        if let customImage = UIImage(named: "pageStick") {
            let resizedImage = customImage.resized(toSize: CGSize(width: 40, height: 5))
            pageControl.preferredIndicatorImage = resizedImage
        }
        pageControl.layer.cornerRadius = 10
        pageControl.isUserInteractionEnabled = false
        pageControl.addTarget(self, action: #selector(pageControlValueChanged(_:)), for: .valueChanged)
        return pageControl
    }()
    
    private lazy var pageRightButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(tappedPageRight), for: .touchUpInside)
        return button
    }()
    
    private lazy var pageLeftButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(tappedPageLeft), for: .touchUpInside)
        return button
    }()
    
    private lazy var infoMBTILabel: MBTILabelView = {
        let label = MBTILabelView(mbti: user.mbti, scale: .large)
        label.layer.opacity = 0.9
        return label
    }()
    
    private lazy var infoButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        let image = UIImage(systemName: "info.circle.fill", withConfiguration: imageConfig)
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.tintColor = .picoAlphaWhite
        button.addTarget(self, action: #selector(tappedInfoButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var pickBackButton: UIButton = createHomeButton(iconName: "arrow.uturn.backward", backgroundColor: .lightGray.withAlphaComponent(0.5))
    private lazy var disLikeButton: UIButton = createHomeButton(iconName: "hand.thumbsdown.fill", backgroundColor: .picoBlue.withAlphaComponent(0.8))
    private lazy var likeButton: UIButton = createHomeButton(iconName: "hand.thumbsup.fill", backgroundColor: .picoBlue.withAlphaComponent(0.8))
    
    private lazy var infoHStack: UIStackView = createHomeStack(axis: .horizontal, alignment: .top, spacing: 0)
    private lazy var infoVStack: UIStackView = createHomeStack(axis: .vertical, alignment: nil, spacing: 5)
    
    private lazy var infoNameAgeLabel: UILabel = createHomeLabel(text: "", font: .picoLargeTitleFont, textColor: .white)
    private lazy var infoLocationLabel: UILabel = createHomeLabel(text: "", font: .picoSubTitleFont, textColor: .white)
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        addSubView()
        loadUserImages()
        makeConstraints()
        configButtons()
        configLabels()
        configGesture()
    }
    
    private func addSubView() {
        view.addSubview([scrollView, pageControl, pageRightButton, pageLeftButton, pickBackButton, disLikeButton, likeButton, infoHStack, infoMBTILabel, distanceLabel])
        
        infoHStack.addArrangedSubview(infoVStack)
        infoHStack.addArrangedSubview(infoButton)
        
        infoVStack.addArrangedSubview(infoNameAgeLabel)
        infoVStack.addArrangedSubview(infoLocationLabel)
    }
    private func makeConstraints() {
        let paddingVertical = 25
        let paddingBottom = 30
        let buttonFrame = 65
        
        pageRightButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.trailing.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(view.frame.size.width / 2)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        pageLeftButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(view.frame.size.width / 2)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        pageControl.numberOfPages = user.imageURLs.count
        
        pickBackButton.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(paddingVertical)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-paddingBottom)
            make.width.equalTo(buttonFrame)
            make.height.equalTo(buttonFrame)
        }
        
        disLikeButton.snp.makeConstraints { make in
            make.trailing.equalTo(likeButton.snp.leading).offset(-paddingVertical + 10)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-paddingBottom)
            make.width.equalTo(buttonFrame)
            make.height.equalTo(buttonFrame)
        }
        
        likeButton.snp.makeConstraints { make in
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-paddingVertical)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-paddingBottom)
            make.width.equalTo(buttonFrame)
            make.height.equalTo(buttonFrame)
        }
        
        infoHStack.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(paddingVertical)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-paddingVertical)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-100)
            make.height.equalTo(100)
        }
        
        infoButton.snp.makeConstraints { make in
            make.trailing.equalTo(infoHStack.snp.trailing)
            make.width.height.equalTo(25)
        }
        
        infoMBTILabel.snp.makeConstraints { make in
            make.top.equalTo(infoButton.snp.bottom).offset(40)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(paddingVertical)
            make.bottom.equalTo(infoLocationLabel.snp.bottom).offset(40)
            make.width.equalTo(infoMBTILabel.frame.size.width)
        }
        
        distanceLabel.snp.makeConstraints { make in
            make.top.equalTo(infoNameAgeLabel.snp.bottom)
            make.trailing.equalTo(infoButton)
            make.bottom.equalTo(infoLocationLabel.snp.bottom).offset(10)
            make.width.equalTo(100)
        }
    }
    
    private func configButtons() {
        likeButton.addTarget(self, action: #selector(tappedLikeButton), for: .touchUpInside)
        disLikeButton.addTarget(self, action: #selector(tappedDisLikeButton), for: .touchUpInside)
        pickBackButton.addTarget(self, action: #selector(tappedPickBackButton), for: .touchUpInside)
    }
    
    private func configLabels() {
        infoNameAgeLabel.text = "\(user.nickName), \(user.age)"
        infoLocationLabel.text = user.location.address
        
        distance = calculateDistance(user: user)
        if distance < 1000.0 {
            distanceLabel.text = "가까워요!"
        } else {
            distanceLabel.text = "\(String(format: "%.2f", distance / 1000))km"
        }
        distanceLabel.textColor = .white
        distanceLabel.textAlignment = .right
        distanceLabel.font = .picoSubTitleFont
    }
    
    private func configGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(touchGesture(_:)))
        self.view.addGestureRecognizer(panGesture)
    }
    
    private func createHomeStack(axis: NSLayoutConstraint.Axis, alignment: UIStackView.Alignment?, spacing: CGFloat) -> UIStackView {
        let stack = UIStackView()
        stack.axis = axis
        if let alignment = alignment {
            stack.alignment = alignment
        }
        stack.spacing = spacing
        return stack
    }
    
    private func createHomeLabel(text: String, font: UIFont, textColor: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = textColor
        return label
    }
    
    private func createHomeButton(iconName: String, backgroundColor: UIColor) -> UIButton {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 35, weight: .regular)
        let image = UIImage(systemName: iconName, withConfiguration: imageConfig)
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = backgroundColor
        button.frame = CGRect(x: 0, y: 0, width: 65, height: 65)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        return button
    }
    
    private func loadUserImages() {
        for (index, url) in user.imageURLs.enumerated() {
            let imageView = UIImageView()
            imageView.configBackgroundColor()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 10
            scrollView.addSubview(imageView)
            
            imageView.snp.makeConstraints { make in
                make.leading.equalTo(scrollView).offset(CGFloat(index) * view.frame.size.width + 10)
                make.top.equalTo(scrollView).offset(10)
                make.width.equalTo(view).offset(-20)
                make.height.equalTo(scrollView).offset(-20)
            }
            guard let url = URL(string: url) else { return }
            imageView.kf.setImage(with: url)
            if index == user.imageURLs.count - 1 {
                scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(user.imageURLs.count), height: scrollView.frame.height)
            }
            
            if index == 1 {
                imageView.addSubview(compatibilityView)
                compatibilityView.snp.makeConstraints { make in
                    make.edges.equalTo(imageView)
                }
            }
        }
    }
    
    private func calculateDistance(user: User) -> CLLocationDistance {
        let currentUserLoc = CLLocation(latitude: currentUser.latitude, longitude: currentUser.longitude)
        let otherUserLoc = CLLocation(latitude: user.location.latitude, longitude: user.location.longitude)
        return  currentUserLoc.distance(from: otherUserLoc)
    }
    
    @objc func touchGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.view)
        
        switch gesture.state {
        case .began:
            initialCenter = self.view.center
        case .changed:
            self.view.center = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y)
            self.view.transform = CGAffineTransform(rotationAngle: translation.x / 1000)
            if translation.x > 0 {
                UIView.animate(withDuration: 0.5) {
                    self.homeViewController?.likeLabel.alpha = translation.x / 100
                }
            } else if translation.x < 0 {
                UIView.animate(withDuration: 0.5) {
                    self.homeViewController?.passLabel.alpha = -translation.x / 100
                }
            }
        case .ended:
            if translation.x > 150 {
                HomeUserCardViewModel.cardCounting += 1
                if HomeUserCardViewModel.cardCounting == 3 {
                    HomeUserCardViewModel.cardCounting = -1
                    homeViewController?.addUserCards()
                }

                NotificationService.shared.sendNotification(userId: user.id, sendUserName: currentUser.nickName, notiType: .like)
                guard let myMbti = MBTIType(rawValue: currentUser.mbti) else { return }
                let noti = Noti(receiveId: user.id, sendId: currentUser.userId, name: currentUser.nickName, birth: currentUser.birth, imageUrl: currentUser.imageURL, notiType: .like, mbti: myMbti, createDate: Date().timeIntervalSince1970)
                FirestoreService.shared.saveDocument(collectionId: .notifications, data: noti)

                UIView.animate(withDuration: 0.5) { [self] in
                    viewModel.saveLikeData(receiveUserInfo: user, likeType: .like)
                    homeViewController?.removedView.append(view)
                    view.center.x += 1000
                    homeViewController?.likeLabel.alpha = 0
                }
            } else if translation.x < -150 {
                HomeUserCardViewModel.cardCounting += 1
                if HomeUserCardViewModel.cardCounting == 3 {
                    HomeUserCardViewModel.cardCounting = -1
                    homeViewController?.addUserCards()
                }
                self.viewModel.saveLikeData(receiveUserInfo: user, likeType: .dislike)
                UIView.animate(withDuration: 0.5) { [self] in
                    homeViewController?.removedView.append(view)
                    view.center.x -= 1000
                    homeViewController?.passLabel.alpha = 0
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.view.center = self.initialCenter
                    self.view.transform = CGAffineTransform(rotationAngle: 0)
                    self.homeViewController?.likeLabel.alpha = 0
                    self.homeViewController?.passLabel.alpha = 0
                }
            }
        default:
            break
        }
    }
    @objc func tappedLikeButton() {
        self.homeViewController?.removedView.append(self.view)
        self.homeViewController?.likeLabel.alpha = 1
        self.viewModel.saveLikeData(receiveUserInfo: user, likeType: .like)
        
        HomeUserCardViewModel.cardCounting += 1
        if HomeUserCardViewModel.cardCounting == 3 {
            HomeUserCardViewModel.cardCounting = -1
            homeViewController?.addUserCards()
        }

        NotificationService.shared.sendNotification(userId: user.id, sendUserName: currentUser.nickName, notiType: .like)
        guard let myMbti = MBTIType(rawValue: currentUser.mbti) else { return }
        let noti = Noti(receiveId: user.id, sendId: currentUser.userId, name: currentUser.nickName, birth: currentUser.birth, imageUrl: currentUser.imageURL, notiType: .like, mbti: myMbti, createDate: Date().timeIntervalSince1970)
        FirestoreService.shared.saveDocument(collectionId: .notifications, data: noti)

        UIView.animate(withDuration: 0.5) {
            self.view.center.x += 1000
        } completion: { _ in
            self.homeViewController?.likeLabel.alpha = 0
        }
    }
    
    @objc func tappedDisLikeButton() {
        self.homeViewController?.removedView.append(self.view)
        self.homeViewController?.passLabel.alpha = 1
        self.viewModel.saveLikeData(receiveUserInfo: user, likeType: .dislike)
        HomeUserCardViewModel.cardCounting += 1
        if HomeUserCardViewModel.cardCounting == 3 {
            HomeUserCardViewModel.cardCounting = -1
            homeViewController?.addUserCards()
        }
        UIView.animate(withDuration: 0.5) {
            self.view.center.x -= 1000
        } completion: { _ in
            self.homeViewController?.passLabel.alpha = 0
        }
    }
    
    @objc func tappedPickBackButton() {
        if let lastView = homeViewController?.removedView.last {
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
                        viewModel.purchaseChu(currentChu: remainingChu, purchaseChu: 10)
                        self.viewModel.deleteLikeData()
                        UIView.animate(withDuration: 0.3) {
                            lastView.center = self.view.center
                            lastView.transform = CGAffineTransform(rotationAngle: 0)
                        }
                        self.homeViewController?.removedView.removeLast()
                    } else {
                        showCustomAlert(alertType: .canCancel, titleText: "보유 츄 부족", messageText: "보유하고 있는 츄가 부족합니다. \n현재 츄 : \(UserDefaultsManager.shared.getChuCount()) 개", cancelButtonText: "취소", confirmButtonText: "스토어로 이동", comfrimAction: {
                            let storeViewController = StoreViewController(viewModel: StoreViewModel())
                            self.navigationController?.pushViewController(storeViewController, animated: true)
                        })
                    }
                }
            )
        } else {
            showCustomAlert(alertType: .onlyConfirm, titleText: "첫번째 추천입니다.", messageText: "", confirmButtonText: "확인")
        }
    }
    
    @objc func tappedPageRight() {
        let nextPage = pageControl.currentPage + 1
        let offsetX = CGFloat(nextPage) * scrollView.frame.size.width
        if offsetX < scrollView.frame.size.width * CGFloat(user.imageURLs.count) {
            scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
        }
    }
    
    @objc func tappedPageLeft() {
        let previousPage = pageControl.currentPage - 1
        let offsetX = CGFloat(previousPage) * scrollView.frame.size.width
        if offsetX >= 0 {
            scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
        }
    }
    
    @objc func tappedInfoButton() {
        let viewController = UserDetailViewController()
        viewController.viewModel = UserDetailViewModel(user: user, isHome: true)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func pageControlValueChanged(_ sender: UIPageControl) {
        let offsetX = CGFloat(sender.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
}

extension HomeUserCardViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.frame.size.width != 0 else {
            return
        }
        let pageIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = pageIndex
    }
}
