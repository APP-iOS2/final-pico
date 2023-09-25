//
//  DetailViewController.swift
//  Pico
//
//  Created by 신희권 on 2023/09/25.
//

import UIKit
import SnapKit

final class DetailViewController: UIViewController {
    private let navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar()
        navigationBar.barTintColor = .systemBackground
        return navigationBar
    }()
    
    private let navItem: UINavigationItem = {
        let navigationItem = UINavigationItem(title: "카리나, 24")
        return navigationItem
    }()
    
    private let leftBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .plain, target: DetailViewController.self, action: #selector(tappedNavigationButton))
        barButtonItem.tintColor = .picoFontBlack
        return barButtonItem
    }()
    
    private let rightBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: DetailViewController.self, action: #selector(tappedNavigationButton))
        barButtonItem.tintColor = .picoFontBlack
        return barButtonItem
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private var userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person")
        imageView.tintColor = .black
        return imageView
    }()
    
    private var mbtiImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person")
        imageView.tintColor = .black
        return imageView
    }()
    
    private let nameAgeLabel: UILabel = {
        let label = UILabel()
        label.text = "카리나, 24"
        return label
    }()
    
    private let mapImageView: UIImageView = {
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
        imageView.image = UIImage(systemName: "ruler.fill")
        imageView.tintColor = .black
        return imageView
    }()
    
    private let heightLabel: UILabel = {
        let label = UILabel()
        label.text = "168cm"
        return label
    }()
    
    private let introLabel: UILabel = {
        let label = UILabel()
        label.text = "저랑 블랙맘바 잡으러 가실래요?"
        label.textAlignment = .center
        label.backgroundColor = .picoGray
        return label
    }()
    
    private let educationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "graduationcap.fill")
        imageView.tintColor = .black
        return imageView
    }()
    
    private let educationLabel: UILabel = {
        let label = UILabel()
        label.text = "멋사대학교"
        return label
    }()
    private let religionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "graduationcap.fill")
        imageView.tintColor = .black
        return imageView
    }()
    
    private let religionLabel: UILabel = {
        let label = UILabel()
        label.text = "불교"
        return label
    }()
    
    private let smokeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "smoke")
        imageView.tintColor = .black
        return imageView
    }()
    
    private let smokeLabel: UILabel = {
        let label = UILabel()
        label.text = "비흡연"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addsubViews()
        makeConstraints()
        configureNavigationBar()
    }
    
    @objc func tappedNavigationButton() {
        // Action
    }
    
    private func configureNavigationBar() {
        navItem.leftBarButtonItem = leftBarButton
        navItem.rightBarButtonItem = rightBarButton
        navigationBar.setItems([navItem], animated: true)
    }
    
    final private func addsubViews() {
        [scrollView, navigationBar].forEach {
            view.addSubview($0)
        }
        let views = [userImageView, nameAgeLabel, mapImageView, locationLabel, heightImageView, heightLabel, introLabel]
        views.forEach {
            scrollView.addSubview($0)
        }
    }
    
    final private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        navigationBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeArea)
        }
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.leading.trailing.bottom.equalTo(safeArea)
        }
        userImageView.snp.makeConstraints { make in
            make.width.equalTo(scrollView)
            make.height.equalTo(250)
        }
        nameAgeLabel.snp.makeConstraints { make in
            make.top.equalTo(userImageView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        mapImageView.snp.makeConstraints { make in
            make.top.equalTo(nameAgeLabel.snp.bottom).offset(10)
            make.leading.equalTo(scrollView).offset(20)
        }
        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(nameAgeLabel.snp.bottom).offset(10)
            make.leading.equalTo(mapImageView.snp.trailing).offset(5)
        }
        heightImageView.snp.makeConstraints { make in
            make.top.equalTo(locationLabel.snp.bottom).offset(10)
            make.leading.equalTo(scrollView).offset(20)
        }
        heightLabel.snp.makeConstraints { make in
            make.top.equalTo(locationLabel.snp.bottom).offset(10)
            make.leading.equalTo(heightImageView.snp.trailing).offset(5)
        }
        introLabel.snp.makeConstraints { make in
            make.top.equalTo(heightLabel.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
        }
    }
}
