//
//  UserImageTableViewCell.swift
//  Pico
//
//  Created by 신희권 on 2023/10/04.
//

import UIKit
import RxSwift
import RxCocoa

struct UserImageViewControllConstraint {
    static let height: CGFloat = Screen.height * 0.6
}

final class UserImageViewControll: UIViewController {
    private let disposeBag = DisposeBag()
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.white
        return pageControl
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        makeConstraints()
        configScrollView()
    }
    
    private func configScrollView() {
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
    }
    
    func config(images: [String]) {
        
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(images.count), height: scrollView.bounds.height)
        pageControl.numberOfPages = images.count
        for (index, image) in images.enumerated() {
            let imageView = UIImageView()
            if let image = URL(string: image) {
                imageView.kf.setImage(with: image)
            }
            imageView.contentMode = .scaleAspectFill
            imageView.frame = CGRect(x: UIScreen.main.bounds.width * CGFloat(index),
                                     y: 0,
                                     width: UIScreen.main.bounds.width,
                                     height: UserImageViewControllConstraint.height)
            scrollView.addSubview(imageView)
        }
    }
    
    private func addViews() {
        [scrollView, pageControl].forEach { view.addSubview($0) }
    }
    
    private func makeConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        pageControl.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
        }
    }
}

extension UserImageViewControll: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pageControl.currentPage = Int(floor(scrollView.contentOffset.x / UIScreen.main.bounds.width))
        
    }
}
