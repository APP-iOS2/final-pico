//
//  CompatibilityView.swift
//  Pico
//
//  Created by 임대진 on 10/19/23.
//

import UIKit
import SnapKit
import Kingfisher

final class CompatibilityView: UIView {
    private let compatibilityLabel = UILabel()
    private var starImageViews: [UIImageView] = []
    private var starSystemName = ""
    private let compatibilityChart = MBTICompatibilityChart()
    
    private let starStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 4
        view.distribution = .fillEqually
        return view
     }()
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.7)
        return view
     }()
    
    private let myProfileView: UIView = {
       let view = UIView()
        view.layer.cornerRadius = 10
       return view
    }()
    
    private let userProfileView: UIView = {
       let view = UIView()
        view.layer.cornerRadius = 10
       return view
    }()
    
    private let myImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let myMbtiLabel: UILabel = {
        let label = UILabel()
        label.font = .picoMBTILabelFont
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let userMbtiLabel: UILabel = {
        let label = UILabel()
        label.font = .picoMBTILabelFont
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let currentUser: CurrentUser
    private let cardUser: User
    
    init(currentUser: CurrentUser, cardUser: User) {
        self.currentUser = currentUser
        self.cardUser = cardUser
        super.init(frame: .zero)
        addSubView()
        makeConstraints()
        configView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configView() {
        guard let myMbti = MBTIType(rawValue: currentUser.mbti) else { return }
        let compatibility = compatibilityChart.get(mbti1: myMbti, mbti2: cardUser.mbti)
        let starImageView = createStarImageViews(count: compatibility.star)
        
        compatibilityLabel.text = compatibility.information
        compatibilityLabel.font = .picoTitleFont
        compatibilityLabel.textColor = .white.withAlphaComponent(0.9)
        
        starStackView.addArrangedSubview(starImageView)
        
        myImage.kf.setImage(with: URL(string: currentUser.imageURL))
        
        guard let imageUrl = cardUser.imageURLs[safe: 0] else { return }
        userImage.kf.setImage(with: URL(string: imageUrl))
        
        myProfileView.backgroundColor = UIColor(hex: MBTIType(rawValue: currentUser.mbti)?.colorName ?? "#A0CDE5").withAlphaComponent(0.8)
        userProfileView.backgroundColor = UIColor(hex: cardUser.mbti.colorName).withAlphaComponent(0.8)
        
        myMbtiLabel.text = currentUser.mbti.uppercased()
        userMbtiLabel.text = cardUser.mbti.rawValue.uppercased()
    }
    
    private func createStarImageViews(count: Int) -> [UIImageView] {
        for index in 0..<5 {
            let starImage = UIImage(systemName: "star.fill")
            let starImageView = UIImageView(image: starImage)
            if count > index {
                starImageView.tintColor = .picoStarYellow.withAlphaComponent(0.9)
            } else {
                starImageView.tintColor = .gray.withAlphaComponent(0.9)
            }
            starImageViews.append(starImageView)
        }
        return starImageViews
    }
    
    private func addSubView() {
        addSubview([backgroundView, compatibilityLabel, starStackView, myProfileView, userProfileView])
        myProfileView.addSubview([myImage, myMbtiLabel])
        userProfileView.addSubview([userImage, userMbtiLabel])
    }
    
    private func makeConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        compatibilityLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
        }
        
        starStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(compatibilityLabel.snp.bottom).offset(20)
            make.width.equalTo(200)
            make.height.equalTo(30)
        }
        
        myProfileView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalTo(safeAreaLayoutGuide.snp.centerX).offset(-10)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.centerY).offset(-60)
        }
        
        myImage.snp.makeConstraints { make in
            make.top.equalTo(myProfileView).offset(10)
            make.leading.equalTo(myProfileView).offset(10)
            make.trailing.equalTo(myProfileView).offset(-10)
            make.bottom.equalTo(myProfileView).offset(-50)
        }
        
        myMbtiLabel.snp.makeConstraints { make in
            make.top.equalTo(myImage.snp.bottom).offset(10)
            make.leading.equalTo(myProfileView).offset(10)
            make.trailing.equalTo(myProfileView).offset(-10)
            make.bottom.equalTo(myProfileView).offset(-10)
        }
        
        userProfileView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.leading.equalTo(safeAreaLayoutGuide.snp.centerX).offset(10)
            make.trailing.equalToSuperview().offset(-50)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.centerY).offset(-60)
        }
        
        userImage.snp.makeConstraints { make in
            make.top.equalTo(userProfileView).offset(10)
            make.leading.equalTo(userProfileView).offset(10)
            make.trailing.equalTo(userProfileView).offset(-10)
            make.bottom.equalTo(userProfileView).offset(-50)
        }
        
        userMbtiLabel.snp.makeConstraints { make in
            make.top.equalTo(userImage.snp.bottom).offset(10)
            make.leading.equalTo(userProfileView).offset(10)
            make.trailing.equalTo(userProfileView).offset(-10)
            make.bottom.equalTo(userProfileView).offset(-10)
        }
    }
}
