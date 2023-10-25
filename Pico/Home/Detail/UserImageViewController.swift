//
//  UserImageViewController.swift
//  Pico
//
//  Created by 신희권 on 2023/10/04.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

struct UserImageViewControllConstraint {
    static let height: CGFloat = UIScreen.main.bounds.height * 0.6
}

final class UserImageViewController: UIViewController {
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
        pageControl.currentPageIndicatorTintColor = UIColor.picoBlue
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
        scrollView.contentSize = CGSize(width: Screen.width * CGFloat(images.count), height: scrollView.bounds.height)
        pageControl.numberOfPages = images.count
        for index in images.indices {
            let imageView = UIImageView()
            if let image = URL(string: images[index]) {
                imageView.kf.setImage(with: image)
            }
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(x: Screen.width * CGFloat(index),
                                     y: 0,
                                     width: Screen.width,
                                     height: UserImageViewControllConstraint.height)
            scrollView.addSubview(imageView)
        }
    }
}

// MARK: - UI관련
extension UserImageViewController {
    
    private func addViews() {
        view.addSubview([scrollView, pageControl])
    }
    
    private func makeConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(UserImageViewControllConstraint.height)
        }
        
        pageControl.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
        }
    }
}

extension UserImageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pageControl.currentPage = Int(floor(scrollView.contentOffset.x / UIScreen.main.bounds.width))
    }
}
