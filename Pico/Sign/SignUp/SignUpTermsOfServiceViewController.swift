//
//  SignUpTermsOfServiceViewController.swift
//  Pico
//
//  Created by LJh on 2023/09/27.
//

import UIKit
import SnapKit
import CoreLocation
import RxSwift
import RxRelay

final class SignUpTermsOfServiceViewController: UIViewController {
    let viewModel: SignUpViewModel
    
    init(viewModel: SignUpViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let locationManager = LocationManager()
    private let disposeBag = DisposeBag()
    private var isLoading: Bool = false
    private var isCheckBoxSelected: Bool {
        if firstCheckBoxButton.isSelected && secondCheckBoxButton.isSelected && thirdCheckBoxButton.isSelected {
            return true
        } else {
            return false
        }
    }
    
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = .picoGray
        view.progressTintColor = .picoBlue
        view.layer.cornerRadius = SignView.progressViewCornerRadius
        view.layer.masksToBounds = true
        view.progress = viewModel.progressStatus
        return view
    }()
    
    private let notifyLabel: UILabel = {
        let label = UILabel()
        label.text = "이제 마지막이에요!"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.picoTitleFont
        return label
    }()
    
    private let subNotifyLabel: UILabel = {
        let label = UILabel()
        label.text = "이용약관에 동의해주세요. 😀"
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.textColor = .picoFontGray
        label.font = UIFont.picoDescriptionFont
        return label
    }()
    // MARK: - first

    private let firstTermsOfServiceTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Pico 서비스 이용약관"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.picoSubTitleFont
        return label
    }()
    
    private lazy var firstTermsOfServiceButton: UIButton = {
        let button = CommonButton(type: .custom)
        button.setTitle("서비스 이용약관 보기", for: .normal)
        button.tag = 0
        button.backgroundColor = .picoGray
        button.addTarget(self, action: #selector(tappedTermsOfServiceButton), for: .touchUpInside)
        return button
    }()
    
    private let firstTermsAgreementLabel: UILabel = {
        let label = UILabel()
        label.text = "Pico 서비스 이용약관에 동의합니다."
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.picoDescriptionFont
        label.textColor = .picoFontGray
        return label
    }()

    private lazy var firstCheckBoxButton: UIButton = {
        let button = UIButton(type: .custom)
        let uncheckedImage = UIImage(systemName: "checkmark.circle")
        let checkedImage = UIImage(systemName: "checkmark.circle.fill")
        
        button.setImage(uncheckedImage, for: .normal)
        button.setImage(checkedImage, for: .selected)
        button.tintColor = .picoFontGray
        button.addTarget(self, action: #selector(tappedCheckBoxButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - second
    private let secondTermsOfServiceTextLabel: UILabel = {
        let label = UILabel()
        label.text = "개인정보 수집 및 이용약관"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.picoSubTitleFont
        return label
    }()
    
    private lazy var secondTermsOfServiceButton: UIButton = {
        let button = CommonButton(type: .custom)
        button.setTitle("개인정보 수집 및 이용약관 보기", for: .normal)
        button.tag = 1
        button.backgroundColor = .picoGray
        button.addTarget(self, action: #selector(tappedTermsOfServiceButton), for: .touchUpInside)
        return button
    }()
    
    private let secondTermsAgreementLabel: UILabel = {
        let label = UILabel()
        label.text = "개인정보 수집에 동의합니다."
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.picoDescriptionFont
        label.textColor = .picoFontGray
        return label
    }()

    private lazy var secondCheckBoxButton: UIButton = {
        let button = UIButton(type: .custom)
        let uncheckedImage = UIImage(systemName: "checkmark.circle")
        let checkedImage = UIImage(systemName: "checkmark.circle.fill")
        
        button.setImage(uncheckedImage, for: .normal)
        button.setImage(checkedImage, for: .selected)
        button.tintColor = .picoFontGray
        button.addTarget(self, action: #selector(tappedCheckBoxButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - third
    private let thirdTermsOfServiceTextLabel: UILabel = {
        let label = UILabel()
        label.text = "위치기반 서비스 이용약관"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.picoSubTitleFont
        return label
    }()
    
    private lazy var thirdTermsOfServiceButton: UIButton = {
        let button = CommonButton(type: .custom)
        button.setTitle("위치기반 서비스 이용약관 보기", for: .normal)
        button.tag = 2
        button.backgroundColor = .picoGray
        button.addTarget(self, action: #selector(tappedTermsOfServiceButton), for: .touchUpInside)
        return button
    }()
    
    private let thirdTermsAgreementLabel: UILabel = {
        let label = UILabel()
        label.text = "위치기반 서비스에 동의합니다."
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.picoDescriptionFont
        label.textColor = .picoFontGray
        return label
    }()

    private lazy var thirdCheckBoxButton: UIButton = {
        let button = UIButton(type: .custom)
        let uncheckedImage = UIImage(systemName: "checkmark.circle")
        let checkedImage = UIImage(systemName: "checkmark.circle.fill")
        
        button.setImage(uncheckedImage, for: .normal)
        button.setImage(checkedImage, for: .selected)
        button.tintColor = .picoFontGray
        button.addTarget(self, action: #selector(tappedCheckBoxButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let button = CommonButton(type: .custom)
        button.setTitle("완료", for: .normal)
        button.backgroundColor = .picoGray
        button.isEnabled = false
        button.addTarget(self, action: #selector(tappedNextButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.configBackgroundColor()
        configNavigationBackButton()
        addSubViews()
        makeConstraints()
        viewModel.isSaveSuccess
            .observe(on: MainScheduler.instance)
            .bind { [weak self] _ in
                guard let self = self else { return }
                showCustomAlert(alertType: .onlyConfirm, titleText: "알림", messageText: "회원가입이 완료되었습니다! 🎉", confirmButtonText: "확인", comfrimAction: { [weak self] in
                    guard let self = self else { return }
                    
                    navigationController?.popToRootViewController(animated: true)
                })
            }
            .disposed(by: disposeBag)
    }
    override func viewDidAppear(_ animated: Bool) {
        viewModel.animateProgressBar(progressView: progressView, endPoint: 7)
    }
}

extension SignUpTermsOfServiceViewController {
    // MARK: - update
    private func updateNextButton(isCheck: Bool) {
        nextButton.isEnabled = isCheck
        nextButton.backgroundColor = isCheck ? .picoBlue : .picoGray
    }
    
    // MARK: - @objc
    @objc private func tappedCheckBoxButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.tintColor = sender.isSelected ? .picoAlphaBlue : .picoFontGray
        updateNextButton(isCheck: isCheckBoxSelected)
    }
    
    @objc private func tappedTermsOfServiceButton(_ sender: UIButton) {
        sender.backgroundColor = .picoAlphaBlue
        present(TermsOfServiceModalViewController(tag: sender.tag), animated: true)
    }
    
    @objc private func tappedNextButton(_ sender: UIButton) {
        // 위도 경도
        let space = locationManager.locationManager.location?.coordinate
        let lat = space?.latitude
        let long = space?.longitude
        
        locationManager.getAddress(latitude: lat, longitude: long) { [weak self] location in
            guard let self = self else { return }
            
            if let location = location {
                viewModel.locationSubject.onNext(location)
            } else {
                locationManager.accessLocation()
            }
        }
    }
}
// MARK: - UI관련
extension SignUpTermsOfServiceViewController {
    private func addSubViews() {
        for viewItem in [progressView, notifyLabel, subNotifyLabel,
                         firstCheckBoxButton, firstTermsOfServiceTextLabel,
                         firstTermsAgreementLabel, firstTermsOfServiceButton,
                         secondTermsOfServiceTextLabel, secondCheckBoxButton,
                         secondTermsOfServiceButton, secondTermsAgreementLabel,
                         thirdTermsOfServiceTextLabel, thirdCheckBoxButton,
                         thirdTermsAgreementLabel, thirdTermsOfServiceButton,
                         nextButton] {
                view.addSubview(viewItem)
            }
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(SignView.progressViewTopPadding)
            make.leading.equalTo(SignView.padding)
            make.trailing.equalTo(-SignView.padding)
            make.height.equalTo(8)
        }
        
        notifyLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(SignView.padding)
            make.leading.equalTo(SignView.padding)
            make.trailing.equalTo(-SignView.padding)
        }
        
        subNotifyLabel.snp.makeConstraints { make in
            make.top.equalTo(notifyLabel.snp.bottom).offset(SignView.subPadding)
            make.leading.equalTo(SignView.padding)
            make.trailing.equalTo(-SignView.padding)
        }
        
        firstTermsOfServiceTextLabel.snp.makeConstraints { make in
            make.top.equalTo(subNotifyLabel.snp.bottom).offset(SignView.padding + 10)
            make.leading.equalTo(SignView.padding)
            make.trailing.equalTo(-SignView.padding)
        }
        
        firstTermsOfServiceButton.snp.makeConstraints { make in
            make.top.equalTo(firstTermsOfServiceTextLabel.snp.bottom).offset(SignView.padding - 5)
            make.leading.equalTo(SignView.padding)
            make.trailing.equalTo(-SignView.padding)
            make.height.equalTo(CommonConstraints.buttonHeight - 10)
        }
        
        firstCheckBoxButton.snp.makeConstraints { make in
                make.top.equalTo(firstTermsOfServiceButton.snp.bottom)
                make.leading.equalTo(SignView.padding)
                make.width.height.equalTo(30) // 적절한 크기로 설정
        }
        
        firstTermsAgreementLabel.snp.makeConstraints { make in
                make.centerY.equalTo(firstCheckBoxButton.snp.centerY)
                make.leading.equalTo(firstCheckBoxButton.snp.trailing)
                make.trailing.equalTo(-SignView.padding)
        }
        
        secondTermsOfServiceTextLabel.snp.makeConstraints { make in
            make.top.equalTo(firstCheckBoxButton.snp.bottom).offset(SignView.padding)
            make.leading.equalTo(SignView.padding)
            make.trailing.equalTo(-SignView.padding)
        }
        
        secondTermsOfServiceButton.snp.makeConstraints { make in
            make.top.equalTo(secondTermsOfServiceTextLabel.snp.bottom).offset(SignView.padding - 5)
            make.leading.equalTo(SignView.padding)
            make.trailing.equalTo(-SignView.padding)
            make.height.equalTo(CommonConstraints.buttonHeight - 10)
        }
        
        secondCheckBoxButton.snp.makeConstraints { make in
                make.top.equalTo(secondTermsOfServiceButton.snp.bottom)
                make.leading.equalTo(SignView.padding).offset(SignView.padding)
                make.width.height.equalTo(30) // 적절한 크기로 설정
        }
        
        secondTermsAgreementLabel.snp.makeConstraints { make in
                make.centerY.equalTo(secondCheckBoxButton.snp.centerY)
                make.leading.equalTo(secondCheckBoxButton.snp.trailing)
                make.trailing.equalTo(-SignView.padding)
        }
        
        thirdTermsOfServiceTextLabel.snp.makeConstraints { make in
            make.top.equalTo(secondCheckBoxButton.snp.bottom).offset(SignView.padding)
            make.leading.equalTo(SignView.padding)
            make.trailing.equalTo(-SignView.padding)
        }
        
        thirdTermsOfServiceButton.snp.makeConstraints { make in
            make.top.equalTo(thirdTermsOfServiceTextLabel.snp.bottom).offset(SignView.padding - 5)
            make.leading.equalTo(SignView.padding)
            make.trailing.equalTo(-SignView.padding)
            make.height.equalTo(CommonConstraints.buttonHeight - 10)
        }
        
        thirdCheckBoxButton.snp.makeConstraints { make in
                make.top.equalTo(thirdTermsOfServiceButton.snp.bottom)
                make.leading.equalTo(SignView.padding)
                make.width.height.equalTo(30) // 적절한 크기로 설정
        }
        
        thirdTermsAgreementLabel.snp.makeConstraints { make in
                make.centerY.equalTo(thirdCheckBoxButton.snp.centerY)
                make.leading.equalTo(thirdCheckBoxButton.snp.trailing)
                make.trailing.equalTo(-SignView.padding)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.equalTo(notifyLabel.snp.leading)
            make.trailing.equalTo(notifyLabel.snp.trailing)
            make.bottom.equalTo(safeArea).offset(SignView.bottomPadding)
            make.height.equalTo(CommonConstraints.buttonHeight)
        }
    }
}
