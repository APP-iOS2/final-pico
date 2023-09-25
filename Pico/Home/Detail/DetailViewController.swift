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
        barButtonItem.tintColor = .black
        return barButtonItem
    }()
    
    private let rightBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: DetailViewController.self, action: #selector(tappedNavigationButton))
        barButtonItem.tintColor = .black
        return barButtonItem
    }()
    
    private let vStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
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
        label.text = "저랑 블랙맘바 잡으러 가실래요?저랑 블랙맘바 잡으러 가실래요?저랑 블랙맘바 잡으러 가실래요?저랑 블랙맘바 잡으러 가실래요?"
        label.textAlignment = .center
        label.backgroundColor = .picoGray
        label.numberOfLines = 0
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
        imageView.image = UIImage(systemName: "hands.sparkles.fill")
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
        addViews()
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
    
    final private func addViews() {
        let views = [userImageView, nameAgeLabel, locationImageView, locationLabel, heightImageView, heightLabel, introLabel, educationImageView, educationLabel, religionImageView, religionLabel, smokeImageView, smokeLabel]
        [vStackView, navigationBar].forEach { view.addSubview($0) }
        views.forEach { vStackView.addSubview($0) }
    }
    
    final private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        navigationBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeArea)
        }
        
        vStackView.snp.makeConstraints { make in
            make.edges.equalTo(safeArea)
        }
        
        userImageView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.width.equalTo(vStackView)
            make.height.equalTo(250)
        }
        
        nameAgeLabel.snp.makeConstraints { make in
            make.top.equalTo(userImageView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        locationImageView.snp.makeConstraints { make in
            make.top.equalTo(nameAgeLabel.snp.bottom).offset(10)
            make.leading.equalTo(vStackView).offset(20)
        }
        
        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(locationImageView.snp.top)
            make.leading.equalTo(locationImageView.snp.trailing).offset(5)
            //  make.trailing.equalToSuperview().offset(-20) 왜 이미지가 늘어날까요
        }
        
        heightImageView.snp.makeConstraints { make in
            make.top.equalTo(locationLabel.snp.bottom).offset(10)
            make.leading.equalTo(vStackView).offset(20)
        }
        
        heightLabel.snp.makeConstraints { make in
            make.top.equalTo(heightImageView.snp.top)
            make.leading.equalTo(heightImageView.snp.trailing).offset(5)
        }
        
        introLabel.snp.makeConstraints { make in
            make.top.equalTo(heightLabel.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        educationImageView.snp.makeConstraints { make in
            make.top.equalTo(introLabel.snp.bottom).offset(30)
            make.leading.equalTo(vStackView).offset(20)
        }
        
        educationLabel.snp.makeConstraints { make in
            make.top.equalTo(educationImageView.snp.top)
            make.leading.equalTo(heightImageView.snp.trailing).offset(5)
        }
        
        religionImageView.snp.makeConstraints { make in
            make.top.equalTo(educationImageView.snp.bottom).offset(15)
            make.leading.equalTo(vStackView).offset(20)
        }
        
        religionLabel.snp.makeConstraints { make in
            make.top.equalTo(religionImageView.snp.top)
            make.leading.equalTo(heightImageView.snp.trailing).offset(5)
        }
    }
}
