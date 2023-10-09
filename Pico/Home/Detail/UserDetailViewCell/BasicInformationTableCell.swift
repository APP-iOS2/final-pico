//
//  TopUserDetailViewController.swift
//  Pico
//
//  Created by 신희권 on 2023/09/25.
//

import UIKit

final class BasicInformationTableCell: UITableViewCell {
    private var mbtiLabelView: MBTILabelView = MBTILabelView(mbti: .infp, scale: .large)
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
        self.configBackgroundColor()
        addViews()
        makeConstraints()
        
    }
    
    func config(mbti: MBTIType, nameAgeText: String, locationText: String, heightText: String) {
        mbtiLabelView = MBTILabelView(mbti: mbti, scale: .large)
        nameAgeLabel.text = nameAgeText
        locationLabel.text = locationText
        heightLabel.text = "\(heightText) cm"
    }
    
    private func addViews() {
        [mbtiLabelView, nameAgeLabel, locationLabel, locationImageView, heightLabel, heightImageView].forEach { addSubview($0) }
    }
    
    private func makeConstraints() {
        let safeArea = safeAreaLayoutGuide
                mbtiLabelView.snp.makeConstraints { make in
                    make.top.leading.equalToSuperview().offset(20)
                    
                    make.width.equalTo(70)
                    make.height.equalTo(50)
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
