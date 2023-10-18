//
//  MiddleUserDetailViewController.swift
//  Pico
//
//  Created by 신희권 on 2023/09/25.
//

import UIKit

final class AboutMeViewController: UIViewController {
    
    private let introLabelContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .picoGray
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let introLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private let educationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "graduationcap.fill")
        imageView.tintColor = .gray
        return imageView
    }()
    
    private let educationLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        return label
    }()
    
    private let religionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "hands.sparkles.fill")
        imageView.tintColor = .gray
        return imageView
    }()
    
    private let religionLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        return label
    }()
    
    private let smokeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "smoke")
        imageView.tintColor = .gray
        return imageView
    }()
    
    private let smokeLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        return label
    }()
    
    private let jobImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "building.columns.fill")
        imageView.tintColor = .gray
        return imageView
    }()
    
    private let jobLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        return label
    }()
    
    private let drinkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "wineglass.fill")
        imageView.tintColor = .gray
        return imageView
    }()
    
    private let drinkLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        makeConstraints()
    }
    
    func config(intro: String?, eduText: String?, religionText: String?, smokeText: String?, jobText: String?, drinkText: String?) {
        introLabel.text = intro
        educationLabel.text = eduText
        religionLabel.text = religionText
        smokeLabel.text = smokeText
        jobLabel.text = jobText
        drinkLabel.text = jobText
    }
    
    private func addViews() {
        let views = [introLabelContainerView, educationImageView, educationLabel, religionImageView, religionLabel, smokeImageView, smokeLabel, jobImageView, jobLabel, drinkImageView, drinkLabel]
        views.forEach {  view.addSubview($0) }
        introLabelContainerView.addSubview(introLabel)
    }
    
    private func makeConstraints() {
        introLabelContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        introLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10))
        }
        
        educationImageView.snp.makeConstraints { make in
            make.top.equalTo(introLabelContainerView.snp.bottom).offset(30)
            make.leading.equalToSuperview()
            make.width.equalTo(25)
        }
        
        educationLabel.snp.makeConstraints { make in
            make.top.equalTo(educationImageView.snp.top)
            make.leading.equalTo(educationImageView.snp.trailing).offset(5)
        }
        
        religionImageView.snp.makeConstraints { make in
            make.top.equalTo(educationImageView.snp.bottom).offset(30)
            make.leading.equalToSuperview()
        }
        
        religionLabel.snp.makeConstraints { make in
            make.top.equalTo(religionImageView.snp.top)
            make.leading.equalTo(educationImageView.snp.trailing).offset(5)
        }
        
        smokeImageView.snp.makeConstraints { make in
            make.top.equalTo(religionImageView.snp.bottom).offset(30)
            make.leading.equalToSuperview()
        }
        
        smokeLabel.snp.makeConstraints { make in
            make.top.equalTo(smokeImageView.snp.top)
            make.leading.equalTo(educationImageView.snp.trailing).offset(5)
        }
        
        jobImageView.snp.makeConstraints { make in
            make.top.equalTo(educationLabel.snp.top)
            make.leading.equalTo(educationLabel.snp.trailing).offset(80)
        }
        
        jobLabel.snp.makeConstraints { make in
            make.top.equalTo(jobImageView.snp.top)
            make.leading.equalTo(jobImageView.snp.trailing).offset(5)
        }
        
        drinkImageView.snp.makeConstraints { make in
            make.top.equalTo(religionLabel.snp.top)
            make.leading.equalTo(jobImageView.snp.leading)
        }
        
        drinkLabel.snp.makeConstraints { make in
            make.top.equalTo(drinkImageView.snp.top)
            make.leading.equalTo(jobLabel.snp.leading)
        }
    }
}
