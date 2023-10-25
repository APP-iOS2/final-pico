//
//  DetailUserImageTableViewCell.swift
//  Pico
//
//  Created by 최하늘 on 10/13/23.
//

import UIKit
import SnapKit

final class DetailUserImageTableViewCell: UITableViewCell {
    
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
    
    // MARK: - initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addViews()
        makeConstraints()
        configScrollView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            if UIDevice.current.model.contains("iPhone") {
                imageView.contentMode = .scaleAspectFill
            } else if UIDevice.current.model.contains("iPad") {
                imageView.contentMode = .scaleAspectFit
            }
            imageView.frame = CGRect(x: UIScreen.main.bounds.width * CGFloat(index),
                                     y: 0,
                                     width: UIScreen.main.bounds.width,
                                     height: UserImageViewControllConstraint.height)
            scrollView.addSubview(imageView)
        }
    }
    
    private func addViews() {
        contentView.addSubview([scrollView, pageControl])
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

extension DetailUserImageTableViewCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pageControl.currentPage = Int(floor(scrollView.contentOffset.x / UIScreen.main.bounds.width))
    }
}
