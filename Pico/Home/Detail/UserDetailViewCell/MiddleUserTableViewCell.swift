//
//  MiddleUserDetailViewController.swift
//  Pico
//
//  Created by 신희권 on 2023/09/25.
//

import UIKit

final class MiddleUserTableViewCell: UITableViewCell {
    private let introLabel: UILabel = {
        let label = UILabel()
        label.text = "저랑 블랙맘바 잡으러 가실래요??저랑 블랙맘바 잡으러 가실래요??저랑 블랙맘바 잡으러 가실래요??가실래요??래요??가실래요??래요??가실래요??"
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
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
    
    private let jobImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "building.columns.fill")
        imageView.tintColor = .black
        return imageView
    }()
    
    private let jobLabel: UILabel = {
        let label = UILabel()
        label.text = "Aespa"
        return label
    }()
    
    private let drinkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "wineglass.fill")
        imageView.tintColor = .black
        return imageView
    }()
    
    private let drinkLabel: UILabel = {
        let label = UILabel()
        label.text = "전혀 안함"
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addViews()
        makeConstraints()
    }
    
    func config(eduText: String, religionText: String, smokeText: String, jobText: String, drinkText: String) {
        educationLabel.text = eduText
        religionLabel.text = religionText
        smokeLabel.text = smokeText
        jobLabel.text = jobText
        drinkLabel.text = jobText
    }
    
    private func addViews() {
        let views = [introLabel, educationImageView, educationLabel, religionImageView, religionLabel, smokeImageView, smokeLabel, jobImageView, jobLabel, drinkImageView, drinkLabel]
        views.forEach { self.addSubview($0) }
    }
    
    private func makeConstraints() {
        
        introLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        educationImageView.snp.makeConstraints { make in
            make.top.equalTo(introLabel.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(20)
        }
        
        educationLabel.snp.makeConstraints { make in
            make.top.equalTo(educationImageView.snp.top)
            make.leading.equalTo(educationImageView.snp.trailing).offset(5)
        }
        
        religionImageView.snp.makeConstraints { make in
            make.top.equalTo(educationImageView.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(20)
        }
        
        religionLabel.snp.makeConstraints { make in
            make.top.equalTo(religionImageView.snp.top)
            make.leading.equalTo(educationImageView.snp.trailing).offset(5)
        }
        
        smokeImageView.snp.makeConstraints { make in
            make.top.equalTo(religionImageView.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(20)
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
            make.leading.equalTo(drinkImageView.snp.trailing).offset(5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
