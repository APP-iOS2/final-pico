//
//  TopUserDetailViewController.swift
//  Pico
//
//  Created by 신희권 on 2023/09/25.
//

import UIKit
import SnapKit

final class BasicInformationViewContoller: UIViewController {
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 10
        return stackView
    }()
    
    private let locationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.spacing = 5
        return stackView
    }()
    
    private let heightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.spacing = 5
        return stackView
    }()
    
    private var mbtiLabelView: MBTILabelView = MBTILabelView(mbti: .enfj, scale: .large)
    private let nameAgeLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .picoLargeTitleFont
        return label
    }()
    
    private let locationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "map")
        imageView.tintColor = .gray
        return imageView
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .picoSubTitleFont
        return label
    }()
    
    private let heightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "ruler")
        imageView.tintColor = .gray
        return imageView
    }()
    
    private let heightLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .picoSubTitleFont
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addViews()
        makeConstraints()
        
    }
    
    func config(mbti: MBTIType, nameAgeText: String, locationText: String, heightText: String?) {
        mbtiLabelView.setMbti(mbti: mbti)
        nameAgeLabel.text = nameAgeText
        locationLabel.text = locationText
        
        if let heightText = heightText {
            heightLabel.text = " \(heightText)cm"
        } else {
            [heightImageView, heightLabel].forEach {
                verticalStackView.removeArrangedSubview(heightStackView)
                $0.isHidden = true
            }
        }
    }
}

// MARK: - UI 관련
extension BasicInformationViewContoller {
    private func addViews() {
        view.addSubview([mbtiLabelView, verticalStackView])
        locationStackView.addArrangedSubview([locationImageView, locationLabel])
        heightStackView.addArrangedSubview([heightImageView, heightLabel])
        verticalStackView.addArrangedSubview([nameAgeLabel, locationStackView, heightStackView])
    }
    
    private func makeConstraints() {
        mbtiLabelView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.width.equalTo(65)
            make.height.equalTo(35)
        }
        verticalStackView.snp.makeConstraints { make in
            make.top.equalTo(mbtiLabelView.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        locationImageView.snp.makeConstraints { make in
            make.top.equalTo(nameAgeLabel.snp.bottom).offset(15)
            make.width.height.equalTo(20)
        }

        heightImageView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
        }
    }
}
