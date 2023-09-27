//
//  HomeTabImageViewController.swift
//  Pico
//
//  Created by 임대진 on 2023/09/25.
//

import UIKit
import SnapKit

final class HomeTabImageViewController: UIViewController {
    
    private let name: String
    private let age: String
    
    init(name: String, age: String) {
        self.name = name
        self.age = age
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let imageUrl: [String] = [
        "https://image5jvqbd.fmkorea.com/files/attach/new2/20211225/3655109/3113058505/4195166827/e130faca7194985e4f162b3583d52853.jpg",
        "https://img.dmitory.com/img/202107/2lh/a8H/2lha8HnRr6Q046GGGQ0uwM.jpg",
        "https://i.namu.wiki/i/jUHcYJjORbNSurOw8cwl-g8jduAT01mhJJkF5oDbvyae_1hkSExnUQ0I5fDKgebUKzSFjSFhRheeSI9-rfpuDU8RJ9wqo5KwIodMVjuzKT2o6RK0IutUtsKWZrYxzT-cOvxKhbPm9c3PXo5H-OvBCA.webp",
        "https://img.dmitory.com/img/202107/2lh/a8H/2lha8HnRr6Q046GGGQ0uwM.jpg",
        "https://img.dmitory.com/img/202107/2lh/a8H/2lha8HnRr6Q046GGGQ0uwM.jpg"
    ]
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.pageIndicatorTintColor = UIColor.gray
        if let customImage = UIImage(named: "pageStick") {
            let resizedImage = customImage.resized(toSize: CGSize(width: 40, height: 5))
            pageControl.preferredIndicatorImage = resizedImage
        }
        pageControl.layer.cornerRadius = 10
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()
    
    private lazy var pickBackButton: UIButton = createHomeButton(iconName: "arrow.uturn.backward", backgroundColor: .lightGray.withAlphaComponent(0.5))
    private lazy var disLikeButton: UIButton = createHomeButton(iconName: "hand.thumbsdown.fill", backgroundColor: .picoBlue.withAlphaComponent(0.8))
    private lazy var likeButton: UIButton = createHomeButton(iconName: "hand.thumbsup.fill", backgroundColor: .picoBlue.withAlphaComponent(0.8))
    
    private lazy var infoHStack: UIStackView = createHomeStack(axis: .horizontal, alignment: .top, spacing: 0)
    private lazy var infoVStack: UIStackView = createHomeStack(axis: .vertical, alignment: nil, spacing: 5)
    
    private lazy var infoNameAgeLabel: UILabel = createHomeLabel(text: "", font: .picoTitleFont, textColor: .white)
    private lazy var infoLocationLabel: UILabel = createHomeLabel(text: "서울특별시 강남구, 12.5km", font: .picoSubTitleFont, textColor: .white)
    private let infoMBTILabel: MBTILabelView = {
        let label = MBTILabelView(mbti: .entp, scale: .large)
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
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        addSubView()
        makeConstraints()
        loadImages()
        infoNameAgeLabel.text = "\(name), \(age)"
        pageControl.addTarget(self, action: #selector(pageControlValueChanged(_:)), for: .valueChanged)
    }
    
    private func addSubView() {
        for viewItem in [scrollView, pageControl, pickBackButton, disLikeButton, likeButton, infoHStack] {
            view.addSubview(viewItem)
        }
        infoHStack.addArrangedSubview(infoVStack)
        infoHStack.addArrangedSubview(infoButton)
        infoVStack.addArrangedSubview(infoNameAgeLabel)
        infoVStack.addArrangedSubview(infoLocationLabel)
        view.addSubview(infoMBTILabel)
    }
    private func makeConstraints() {
        
        let paddingVertical = 25
        let paddingBottom = 30
        let buttonFrame = 65
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        pageControl.numberOfPages = imageUrl.count
        
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
    
    private func loadImages() {
        for (index, urlStr) in imageUrl.enumerated() {
            if let url = URL(string: urlStr) {
                let imageView = UIImageView()
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
                
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                        DispatchQueue.main.async { [self] in
                            imageView.image = image
                            
                            if index == imageUrl.count - 1 {
                                scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(imageUrl.count), height: scrollView.frame.height)
                            }
                        }
                    }
                }
            }
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
extension HomeTabImageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.frame.size.width != 0 else {
            return
        }
        let pageIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = pageIndex
    }
}
