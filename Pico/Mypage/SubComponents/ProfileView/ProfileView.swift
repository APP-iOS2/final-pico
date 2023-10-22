//
//  Profile.swift
//  Pico
//
//  Created by 김민기 on 2023/09/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher

final class ProfileView: UIView {
    
    private let userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 70
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "chu")
        return imageView
    }()
    
    private let editImageView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 25
        return view
    }()
    
    private let pencilImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pencilImage")
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .white
        imageView.layer.masksToBounds = false
        imageView.layer.cornerRadius = 15
        return imageView
    }()
    
    private let profilPercentLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 15
        label.textColor = .white
        label.backgroundColor = .picoBlue
        label.font = .picoProfileLabelFont
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
        label.font = UIFont.picoProfileNameFont
        label.textColor = .picoFontBlack
        return label
    }()
    
    private let userAgeLabel: UILabel = {
        let label = UILabel()
        label.font = .picoProfileNameFont
        label.textColor = .picoFontBlack
        return label
    }()
    
    private let circularProgressBarView = CircularProgressBarView()
    private let disposeBag = DisposeBag()
    private var viewModel: ProfileViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configBackgroundColor()
        addViews()
        makeConstraints()
        configProgressBarView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configBaseView(gesture: UIGestureRecognizer) {
        [userImage, editImageView, profilPercentLabel, circularProgressBarView].forEach {
            $0.addGestureRecognizer(gesture)
        }
    }
    
    func configViewModel(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
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
        
        viewModel.imageUrl
                   .observe(on: MainScheduler.instance)
                   .subscribe(onNext: { [weak self] urlString in
                       if let url = URL(string: urlString) {
                           self?.userImage.kf.indicatorType = .custom(indicator: CustomIndicator(cycleSize: .small))
                           self?.userImage.kf.setImage(with: url)
                       }
                   })
                   .disposed(by: disposeBag)
    }

     func configProgressBarView() {
        let circularViewDuration: TimeInterval = 2
        circularProgressBarView.progressAnimation(duration: circularViewDuration)
         circularProgressBarView.triggerLayoutSubviews()
    }
    private func addViews() {
        [userNameLabel, userAgeLabel].forEach {
            stackView.addArrangedSubview($0)
        }
        
        [circularProgressBarView, userImage, editImageView, profilPercentLabel, stackView].forEach {
            addSubview($0)
        }
        
        editImageView.addSubview(pencilImageView)
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
        }
       
        pencilImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
    }
}
