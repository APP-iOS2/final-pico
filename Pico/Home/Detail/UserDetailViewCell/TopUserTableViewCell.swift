//
//  TopUserDetailViewController.swift
//  Pico
//
//  Created by 신희권 on 2023/09/25.
//

import UIKit
private let images: [String] = [
    "https://image5jvqbd.fmkorea.com/files/attach/new2/20211225/3655109/3113058505/4195166827/e130faca7194985e4f162b3583d52853.jpg",
    "https://img.dmitory.com/img/202107/2lh/a8H/2lha8HnRr6Q046GGGQ0uwM.jpg",
    "https://i.namu.wiki/i/jUHcYJjORbNSurOw8cwl-g8jduAT01mhJJkF5oDbvyae_1hkSExnUQ0I5fDKgebUKzSFjSFhRheeSI9-rfpuDU8RJ9wqo5KwIodMVjuzKT2o6RK0IutUtsKWZrYxzT-cOvxKhbPm9c3PXo5H-OvBCA.webp",
    "https://img.dmitory.com/img/202107/2lh/a8H/2lha8HnRr6Q046GGGQ0uwM.jpg",
    "https://img.dmitory.com/img/202107/2lh/a8H/2lha8HnRr6Q046GGGQ0uwM.jpg"
]
final class TopUserTableViewCell: UITableViewCell {
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = images.count
        // 페이지 컨트롤의 현재 페이지를 0으로 설정
        pageControl.currentPage = 0
        // 페이지 표시 색상을 밝은 회색 설정
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        // 현재 페이지 표시 색상을 검정색으로 설정
        pageControl.currentPageIndicatorTintColor = UIColor.black
        return pageControl
    }()
    
    private var userImageView: UIImageView = {
        let imageView = UIImageView()
        if let url = URL(string: images[0]) {
            imageView.load(url: url)
        }
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var mbtiLabelView = MBTILabelView(mbti: .infp)
    
    private let nameAgeLabel: UILabel = {
        let label = UILabel()
        label.text = "카리나, 24"
        label.font = UIFont.picoTitleFont
        return label
    }()
    
    private let locationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "map")
        imageView.tintColor = .black
        return imageView
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "서울시 강남구 1.1km"
        return label
    }()
    
    private let heightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "ruler")
        imageView.tintColor = .black
        return imageView
    }()
    
    private let heightLabel: UILabel = {
        let label = UILabel()
        label.text = "168cm"
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .systemBackground
        addViews()
        makeConstraints()
        
    }
    
    func config(mbti: MBTIType, nameAgeText: String, locationText: String, heightText: String) {
        mbtiLabelView = MBTILabelView(mbti: mbti)
        nameAgeLabel.text = nameAgeText
        locationLabel.text = locationText
        heightLabel.text = "\(heightText) cm"
    }
    
    final private func addViews() {
        [mbtiLabelView, nameAgeLabel, locationLabel, locationImageView, heightLabel, heightImageView, pageControl].forEach { self.addSubview($0) }
        pageControl.addSubview(userImageView)
    }
    
    final private func makeConstraints() {
        let safeArea = self.safeAreaLayoutGuide
        
        pageControl.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalTo(safeArea)
            make.height.equalTo(Screen.height / 1.5)
        }
        
        userImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mbtiLabelView.snp.makeConstraints { make in
            make.top.equalTo(userImageView.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().offset(20)
        }
        
        nameAgeLabel.snp.makeConstraints { make in
            make.top.equalTo(mbtiLabelView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        locationImageView.snp.makeConstraints { make in
            make.top.equalTo(nameAgeLabel.snp.bottom).offset(10)
            make.leading.equalTo(safeArea).offset(20)
        }
        
        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(locationImageView.snp.top)
            make.leading.equalTo(locationImageView.snp.trailing).offset(5)
            //  make.trailing.equalToSuperview().offset(-20) 왜 이미지가 늘어날까요
        }
        
        heightImageView.snp.makeConstraints { make in
            make.top.equalTo(locationLabel.snp.bottom).offset(10)
            make.leading.equalTo(safeArea).offset(20)
        }
        
        heightLabel.snp.makeConstraints { make in
            make.top.equalTo(heightImageView.snp.top)
            make.leading.equalTo(heightImageView.snp.trailing).offset(5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
