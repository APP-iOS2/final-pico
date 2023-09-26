//
//  ViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import SnapKit
import SwiftUI

class HomeViewController: UIViewController {
    
    let imageUrl: [String] = [
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
    
    private let logoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "logo"), for: .normal)
        return button
    }()
    
    private let disLikeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "hand.thumbsdown.fill"), for: .normal)
        button.backgroundColor = .picoHomeBlue
        return button
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "hand.thumbsup.fill"), for: .normal)
        button.tintColor = . white
//        button.backgroundColor = .picoHomeBlue
        return button
    }()
    
    private let pickBackButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "arrow.uturn.backward"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let notificationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "bell.fill"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    private let filterButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "slider.horizontal.3"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        scrollView.delegate = self
        addSubView()
        makeConstraints()
        loadImages()
    }
    
    func addSubView() {
        view.addSubview(navigationBar)
        view.addSubview(logoButton)
        view.addSubview(notificationButton)
        view.addSubview(filterButton)
        view.addSubview(scrollView)
        view.addSubview(pageControl)
        view.addSubview(pickBackButton)
        view.addSubview(disLikeButton)
        view.addSubview(likeButton)
    }
    
    func makeConstraints() {
        
        logoButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-10)
            make.leading.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
        
        notificationButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.trailing.equalTo(filterButton.snp.leading).offset(-20)
        }
        
        filterButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(logoButton.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        pageControl.numberOfPages = imageUrl.count
        
        likeButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
        }
        
    }
    private func loadImages() {
        for (index, urlStr) in imageUrl.enumerated() {
            if let url = URL(string: urlStr) {
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.layer.cornerRadius = 20
                
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
