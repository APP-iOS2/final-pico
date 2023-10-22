//
//  DetailUserInfoTableViewCell.swift
//  Pico
//
//  Created by 최하늘 on 10/12/23.
//

import UIKit
import SnapKit

final class DetailUserInfoTableViewCell: UITableViewCell {
    
    private let mbtiLabelView: MBTILabelView = MBTILabelView(mbti: nil, scale: .large)
    
    private let nameAgeLabel: UILabel = {
        let label = UILabel()
        label.font = .picoTitleFont
        return label
    }()
    
    private let locationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "map")
        imageView.tintColor = .picoFontGray
        return imageView
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .picoFontBlack
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let heightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "ruler")
        imageView.tintColor = .picoFontGray
        imageView.isHidden = true
        return imageView
    }()
    
    private let heightLabel: UILabel = {
        let label = UILabel()
        label.textColor = .picoFontBlack
        return label
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("더보기", for: .normal)
        button.titleLabel?.font = .picoDescriptionFont
        button.setTitleColor(.picoFontGray, for: .normal)
        button.isHidden = true
        return button
    }()
    
    private let sectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .picoFontGray.withAlphaComponent(0.1)
        return view
    }()
    
    // MARK: - initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configBackgroundColor()
        addViews()
        makeConstraints()
        configButtons()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(user: User) {
        mbtiLabelView.setMbti(mbti: user.mbti)
        nameAgeLabel.text = "\(user.nickName), \(user.age)"
        locationLabel.text = user.location.address
        
        if let height = user.subInfo?.height {
            heightImageView.isHidden = false
            moreButton.isHidden = false
            heightLabel.text = "\(String(describing: height)) cm"
            updateConstraint()
        }
    }
    
    private func updateConstraint() {
        sectionView.snp.remakeConstraints { make in
            make.top.equalTo(moreButton.snp.bottom).offset(20)
            make.leading.trailing.equalTo(0)
            make.height.equalTo(10)
            make.bottom.equalTo(-10)
        }
    }
    
    private func configButtons() {
        moreButton.addTarget(self, action: #selector(tappedMoreButton), for: .touchUpInside)
    }
    
    @objc private func tappedMoreButton(_ sender: UIButton) {
        print("더보기")
    }
    
    private func addViews() {
        contentView.addSubview([mbtiLabelView, nameAgeLabel, locationLabel, locationImageView, heightLabel, heightImageView, moreButton, sectionView])
    }
    
    private func makeConstraints() {
        let padding = 10
        
        mbtiLabelView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(padding * 2 - 5)
            make.height.equalTo(mbtiLabelView.frame.size.height)
            make.width.equalTo(mbtiLabelView.frame.size.width)
        }
        
        nameAgeLabel.snp.makeConstraints { make in
            make.top.equalTo(mbtiLabelView.snp.bottom).offset(padding)
            make.leading.trailing.equalToSuperview().inset(padding * 2)
        }
        
        locationImageView.snp.makeConstraints { make in
            make.top.equalTo(nameAgeLabel.snp.bottom).offset(padding)
            make.leading.equalTo(nameAgeLabel.snp.leading)
            make.width.height.equalTo(20)
        }
        
        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(locationImageView.snp.top)
            make.leading.equalTo(locationImageView.snp.trailing).offset(5)
            make.trailing.equalTo(nameAgeLabel.snp.trailing)
        }
        
        heightImageView.snp.makeConstraints { make in
            make.top.equalTo(locationLabel.snp.bottom).offset(padding)
            make.leading.equalTo(nameAgeLabel.snp.leading)
            make.width.height.equalTo(locationImageView.snp.width)
        }
        
        heightLabel.snp.makeConstraints { make in
            make.top.equalTo(heightImageView.snp.top)
            make.leading.equalTo(heightImageView.snp.trailing).offset(5)
            make.trailing.equalTo(nameAgeLabel.snp.trailing)
        }
        
        moreButton.snp.makeConstraints { make in
            make.top.equalTo(heightLabel.snp.bottom).offset(padding * 2)
            make.leading.trailing.equalTo(nameAgeLabel)
            make.height.equalTo(10)
        }
        
        sectionView.snp.makeConstraints { make in
            make.top.equalTo(locationLabel.snp.bottom).offset(20)
            make.leading.trailing.equalTo(0)
            make.height.equalTo(10)
            make.bottom.equalTo(-10)
        }
    }
}
