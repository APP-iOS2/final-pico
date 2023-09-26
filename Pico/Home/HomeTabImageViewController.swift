//
//  HomeTabImageViewController.swift
//  Pico
//
//  Created by 임대진 on 2023/09/25.
//

import UIKit
import SnapKit

final class HomeTabImageViewController: UIViewController {
    
    private let paddingVertical = 25
    private let paddingBottom = 30
    private let buttonFrame = 65
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
    //    private var imageUrl: [String]
    //    init(imageUrl: [String]) {
    //            self.imageUrl = imageUrl
    //            super.init(nibName: nil, bundle: nil)
    //        }
    //
    //    required init?(coder: NSCoder) {
    //        fatalError("init(coder:) has not been implemented")
    //    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.pageIndicatorTintColor = UIColor.gray
        pageControl.preferredIndicatorImage = UIImage(named: "pageStick")
        pageControl.layer.cornerRadius = 10
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()
    
    private let pickBackButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        let image = UIImage(systemName: "arrow.uturn.backward", withConfiguration: imageConfig)
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .gray.withAlphaComponent(0.5)
        button.frame = CGRect(x: 0, y: 0, width: 65, height: 65)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        return button
    }()
    
    private let disLikeButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        let image = UIImage(systemName: "hand.thumbsdown.fill", withConfiguration: imageConfig)
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .picoBlue
        button.frame = CGRect(x: 0, y: 0, width: 65, height: 65)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        return button
    }()
    
    private let likeButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        let image = UIImage(systemName: "hand.thumbsup.fill", withConfiguration: imageConfig)
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .picoBlue
        button.frame = CGRect(x: 0, y: 0, width: 65, height: 65)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        return button
    }()
    
    private let infoHStack: UIStackView = {
        let infoHStack = UIStackView()
        infoHStack.axis = .horizontal
        infoHStack.alignment = .top
//        infoHStack.backgroundColor = .gray.withAlphaComponent(0.5)
        return infoHStack
    }()
    
    private let infoVStack: UIStackView = {
        let infoVStack = UIStackView()
        infoVStack.axis = .vertical
        infoVStack.spacing = 5
        return infoVStack
    }()
    
    private let infoNameAgeLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .picoTitleFont
        label.textColor = .white
        label.font = .systemFont(ofSize: 25, weight: .bold)
        return label
    }()
    
    private let infoLocationLabel: UILabel = {
        let label = UILabel()
        label.text = "서울특별시 강남구, 12.5km"
        label.font = .picoTitleFont
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private let infoMBTILabel: UILabel = {
        let label = UILabel()
        label.text = "ENTP"
        label.textColor = .white
        label.frame = CGRect(x: 0, y: 0, width: 45, height: 25)
//        label.backgroundColor = .picoAlphaBlue
        return label
    }()
    
    private let infoButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        let image = UIImage(systemName: "info.circle.fill", withConfiguration: imageConfig)
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.tintColor = .white.withAlphaComponent(0.8)
        return button
    }()
    
    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        scrollView.delegate = self
        addSubView()
        makeConstraints()
        loadImages()
        infoNameAgeLabel.text = "\(name), \(age)"
        if let customImage = UIImage(named: "pageStick") {
            let resizedImage = customImage.resized(toSize: CGSize(width: 40, height: 5))
            pageControl.preferredIndicatorImage = resizedImage
        }
        pageControl.addTarget(self, action: #selector(pageControlValueChanged(_:)), for: .valueChanged)
        
    }
    
    func addSubView() {
        for viewItem in [scrollView, pageControl, pickBackButton, disLikeButton, likeButton, infoHStack] {
            view.addSubview(viewItem)
        }
        infoHStack.addArrangedSubview(infoVStack)
        infoHStack.addArrangedSubview(infoButton)
        infoVStack.addArrangedSubview(infoNameAgeLabel)
        infoVStack.addArrangedSubview(infoLocationLabel)
        infoVStack.addArrangedSubview(infoMBTILabel)
    }
    
    func makeConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(view.safeAreaLayoutGuide)
            make.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
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
            make.width.equalTo(25)
            make.height.equalTo(25)
        }
        
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
    
    @objc func pageControlValueChanged(_ sender: UIPageControl) {
        let offsetX = CGFloat(sender.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
}

extension HomeTabImageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = pageIndex
    }
}
