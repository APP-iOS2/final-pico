//
//  ViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import SnapKit
import SwiftUI

final class HomeViewController: UIViewController {
    
    private let imageUrl: [String] = [
        "https://image5jvqbd.fmkorea.com/files/attach/new2/20211225/3655109/3113058505/4195166827/e130faca7194985e4f162b3583d52853.jpg",
        "https://img.dmitory.com/img/202107/2lh/a8H/2lha8HnRr6Q046GGGQ0uwM.jpg",
        "https://i.namu.wiki/i/jUHcYJjORbNSurOw8cwl-g8jduAT01mhJJkF5oDbvyae_1hkSExnUQ0I5fDKgebUKzSFjSFhRheeSI9-rfpuDU8RJ9wqo5KwIodMVjuzKT2o6RK0IutUtsKWZrYxzT-cOvxKhbPm9c3PXo5H-OvBCA.webp"
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
    private let navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar()
        return navigationBar
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.black
        pageControl.pageIndicatorTintColor = UIColor.lightGray
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
    private func createButton(imageName: String, backgroundColor: UIColor) -> UIButton {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        let image = UIImage(systemName: imageName, withConfiguration: imageConfig)
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = backgroundColor
        button.frame = CGRect(x: 0, y: 0, width: 65, height: 65)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        return button
    }
    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        scrollView.delegate = self
        configLogoBarItem()
        confignavigationBarItem()
        addSubView()
        makeConstraints()
        loadImages()
    }
    
    func confignavigationBarItem() {
        let notificationImage = UIImage(systemName: "bell.fill")
        let filterImage = UIImage(systemName: "slider.horizontal.3")
        
        let notificationButton = UIBarButtonItem(image: notificationImage, style: .plain, target: nil, action: nil)
        let filterButton = UIBarButtonItem(image: filterImage, style: .plain, target: nil, action: nil)
        
        notificationButton.tintColor = .darkGray
        filterButton.tintColor = .darkGray
        navigationItem.rightBarButtonItems = [notificationButton, filterButton]
    }
    
    func addSubView() {
        view.addSubview(navigationBar)
        view.addSubview(scrollView)
        view.addSubview(pageControl)
        view.addSubview(pickBackButton)
        view.addSubview(disLikeButton)
        view.addSubview(likeButton)
        
    }
    
    func makeConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-5)
        }
        
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
        }
        pageControl.numberOfPages = imageUrl.count
        
        pickBackButton.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.width.equalTo(65)
            make.height.equalTo(65)
        }
        
        disLikeButton.snp.makeConstraints { make in
            make.trailing.equalTo(likeButton.snp.leading).offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.width.equalTo(65)
            make.height.equalTo(65)
        }
        
        likeButton.snp.makeConstraints { make in
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.width.equalTo(65)
            make.height.equalTo(65)
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
                    make.leading.equalTo(scrollView).offset(CGFloat(index) * view.frame.width + 10)
                    make.trailing.equalTo(scrollView).offset(-10)
                    make.top.equalTo(scrollView)
                    make.width.equalTo(view).offset(-20)
                    make.height.equalTo(scrollView)
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
    
}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = pageIndex
    }
}
