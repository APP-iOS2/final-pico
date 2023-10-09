//
//  ProfilViewController.swift
//  Pico
//
//  Created by 김민기 on 2023/09/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ProfilView: UIView {
    
    private let userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 70
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(named: "chu")
        return imageView
    }()
    
    private let editImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pencil")
        imageView.backgroundColor = .white
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 27
        return imageView
    }()
    
    private let profilPercentLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 15
        label.textColor = .white
        label.backgroundColor = .picoBlue
        return label
    }()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 10
        return view
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.picoTitleFont
        return label
    }()
    
    private let userAgeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.picoTitleFont
        return label
    }()
    
    private let circularProgressBarView = CircularProgressBarView()
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configBackgroundColor()
        addViews()
        makeConstraints()
        configProgressBarView()
        bindings(viewModel: ProfileViewModel())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bindings(viewModel: ProfileViewModel) {
        circularProgressBarView.binds(viewModel.circularProgressBarViewModel)
        
        viewModel.userName
            .map {
                $0 + ","
            }
            .bind(to: userNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.userAge
            .bind(to: userAgeLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.profilePerfection
            .map {
                "\($0)% 완료"
            }
            .bind(to: profilPercentLabel.rx.text)
            .disposed(by: disposeBag)
        
    }
    
    private func configProgressBarView() {
        let circularViewDuration: TimeInterval = 2
        circularProgressBarView.progressAnimation(duration: circularViewDuration)
    }
    private func addViews() {
        [circularProgressBarView, userImage, editImageView, profilPercentLabel, stackView].forEach {
            addSubview($0)
        }
        [userNameLabel, userAgeLabel].forEach {
            stackView.addArrangedSubview($0)
        }
    }
    
    private func makeConstraints() {
        
        userImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
            make.width.height.equalTo(140)
        }
        
        circularProgressBarView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
            make.width.height.equalTo(180)
        }
        
        editImageView.snp.makeConstraints { make in
            make.top.equalTo(userImage.snp.top).offset(-10)
            make.trailing.equalTo(userImage.snp.trailing).offset(10)
            make.height.width.equalTo(50)
        }
        
        profilPercentLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(userImage.snp.bottom).offset(-15)
            make.height.equalTo(30)
            make.width.equalTo(80)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(profilPercentLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
    }
}
