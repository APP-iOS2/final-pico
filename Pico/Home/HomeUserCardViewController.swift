//
//  HomeTabImageViewController.swift
//  Pico
//
//  Created by 임대진 on 2023/09/25.
//

import UIKit
import SnapKit
import RxSwift

final class HomeUserCardViewController: UIViewController {
    
    weak var homeViewController: HomeViewController?
    private let user: User
    private let disposeBag = DisposeBag()
    private var panGesture = UIPanGestureRecognizer()
    private var initialCenter = CGPoint()
    private let viewModel = HomeUserCardViewModel()
    
    init(user: User) {
        self.user = user
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
    
    private lazy var infoNameAgeLabel: UILabel = createHomeLabel(text: "", font: .picoTitleFont, textColor: .white)
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
        for viewItem in [scrollView, pageControl, pageRightButton, pageLeftButton, pickBackButton, disLikeButton, likeButton, infoHStack, infoMBTILabel] {
            view.addSubview(viewItem)
        }
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
    }
    
    private func configButtons() {
        likeButton.addTarget(self, action: #selector(tappedLikeButton), for: .touchUpInside)
        disLikeButton.addTarget(self, action: #selector(tappedDisLikeButton), for: .touchUpInside)
        pickBackButton.addTarget(self, action: #selector(tappedPickBackButton), for: .touchUpInside)
    }
    
    private func configLabels() {
        infoNameAgeLabel.text = "\(user.nickName) \(user.birth)"
        infoLocationLabel.text = user.location.address
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
        Loading.showLoading()
        for (index, url) in user.imageURLs.enumerated() {
            
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 10
            imageView.configBackgroundColor()
            scrollView.addSubview(imageView)
            
            imageView.snp.makeConstraints { make in
                make.leading.equalTo(scrollView).offset(CGFloat(index) * view.frame.size.width + 10)
                make.top.equalTo(scrollView).offset(10)
                make.width.equalTo(view).offset(-20)
                make.height.equalTo(scrollView).offset(-20)
            }
            Observable.just(url)
                .map { URL(string: $0)}
                .compactMap { $0 }
                .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
                .map { try Data(contentsOf: $0)}
                .map { UIImage(data: $0)}
                .observe(on: MainScheduler.instance)
                .subscribe { image in
                    imageView.image = image
                    Loading.hideLoading()
                }
                .disposed(by: disposeBag)
            
            if index == user.imageURLs.count - 1 {
                scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(user.imageURLs.count), height: scrollView.frame.height)
            }
        }
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
            if translation.x > 100 {
                UIView.animate(withDuration: 0.5) { [self] in
                    viewModel.saveLikeData(sendUserInfo: viewModel.tempMy, receiveUserInfo: user, likeType: .like)
                    homeViewController?.removedView.append(view)
                    view.center.x += 1000
                    homeViewController?.likeLabel.alpha = 0
                } completion: { _ in
                }
            } else if translation.x < -100 {
                self.viewModel.saveLikeData(sendUserInfo: viewModel.tempMy, receiveUserInfo: user, likeType: .dislike)
                UIView.animate(withDuration: 0.5) { [self] in
                    homeViewController?.removedView.append(view)
                    view.center.x -= 1000
                    homeViewController?.passLabel.alpha = 0
                } completion: { _ in
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
        homeViewController?.removedView.append(self.view)
        self.homeViewController?.likeLabel.alpha = 1
        self.viewModel.saveLikeData(sendUserInfo: viewModel.tempMy, receiveUserInfo: user, likeType: .like)
        UIView.animate(withDuration: 0.3) {
            self.view.center.x += 1000
        } completion: { _ in
            self.homeViewController?.likeLabel.alpha = 0
        }
    }
    
    @objc func tappedDisLikeButton() {
        homeViewController?.removedView.append(self.view)
        self.homeViewController?.passLabel.alpha = 1
        self.viewModel.saveLikeData(sendUserInfo: viewModel.tempMy, receiveUserInfo: user, likeType: .dislike)
        UIView.animate(withDuration: 0.3) {
            self.view.center.x -= 1000
        } completion: { _ in
            self.homeViewController?.passLabel.alpha = 0
        }
    }
    
    @objc func tappedPickBackButton() {
        if let lastView = homeViewController?.removedView.last {
            self.viewModel.deleteLikeData(sendUserInfo: viewModel.tempMy)
            UIView.animate(withDuration: 0.3) {
                lastView.center = self.view.center
                lastView.transform = CGAffineTransform(rotationAngle: 0)
            }
            homeViewController?.removedView.removeLast()
        } else {
            showAlert(message: "첫번째 추천입니다.", yesAction: nil)
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
