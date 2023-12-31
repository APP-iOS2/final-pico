//
//  SignViewController.swift
//  Pico
//
//  Created by LJh on 2023/09/25.
//

import UIKit
import SwiftUI
import SnapKit
import RxSwift
import RxCocoa

enum SignType: CaseIterable, Equatable {
    case none
    case stop(during: Int, endDate: String)
    case block
    case other
    case reuser
    
    var textString: String {
        switch self {
        case .none:
            return ""
        case .stop(let during, let endDate):
            return "해당 계정은 \(during)일 정지로 \(endDate)일까지 로그인이 제한됩니다."
        case .block:
            return "해당 계정은 탈퇴되었습니다.\n복구를 원하시면 고객센터에 문의하세요."
        case .other:
            return "해당 계정은 다른 기기에서 로그인하여 강제 로그아웃이 되었습니다."
        case .reuser:
            return "해당 계정은 복구되었습니다."
        }
    }
    
    static var allCases: [SignType] {
        return [.none, .stop(during: 0, endDate: ""), .block, .other, .reuser]
    }
}

final class SignViewController: UIViewController {
    private lazy var backgroundView: UIView = {
        let view = UIView()
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor.picoGradientMedium2.cgColor, UIColor.picoGradientMedium.cgColor, UIColor.picoBlue.cgColor]
        gradient.locations = [0.0, 0.3, 1.0]
        
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        view.frame = self.view.bounds
        gradient.frame = view.bounds
        view.layer.addSublayer(gradient)
        return view
    }()
    
    private let picoLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo_white")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let signInButton: CommonButton = {
        let button = CommonButton(type: .custom)
        button.setTitle("로그인", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.picoBlue, for: .normal)
        return button
    }()
    
    private let signUpButton: CommonButton = {
        let button = CommonButton(type: .custom)
        button.setTitle("회원가입", for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        return button
    }()
    
    private let disposeBag = DisposeBag()
    private let pictureManager = PictureService()
    private let locationManager = LocationService()
    
    private var signType: SignType
    
    init(signType: SignType = .none) {
        self.signType = signType
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.configBackgroundColor()
        configNavigationBackButton()
        addSubViews()
        makeConstraints()
        configRx()
        locationManager.configLocation()
        configLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        signType = .none
    }
    
    private func configLoad() {
        if isShowSignTypeAlert() {
            showSignTypeAlert()
        }
        
        if VersionService.shared.isOldVersion {
            showVersionAlert()
        }
    }
    
    private func isShowSignTypeAlert() -> Bool {
        return signType != .none ? true : false
    }
    
    private func showSignTypeAlert() {
        showCustomAlert(alertType: .onlyConfirm, titleText: "알림", messageText: signType.textString, confirmButtonText: "확인", comfrimAction: { [weak self] in
            guard let self else { return }
            dismiss(animated: true)
        })
    }
    
    private func showVersionAlert() {
        showCustomAlert(alertType: .onlyConfirm, titleText: "알림", messageText: "업데이트 이후에 사용이 가능합니다.", confirmButtonText: "확인", comfrimAction: {
            self.dismiss(animated: true, completion: {
                if let url = URL(string: VersionService.shared.appStoreOpenUrlString), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
        })
    }
}

extension SignViewController {
    private func configRx() {
        signInButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                signInButton.tappedAnimation()
                let viewController = SignInViewController()
                self.navigationController?.pushViewController(viewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        signUpButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                signUpButton.tappedAnimation()
                let viewController = SignUpViewController()
                self.navigationController?.pushViewController(viewController, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UI관련
extension SignViewController {
    
    private func addSubViews() {
        view.addSubview(backgroundView)
        
        for viewItem in [picoLogoImageView, signInButton, signUpButton] {
            backgroundView.addSubview(viewItem)
        }
    }
    
    private func makeConstraints() {
        let safeArea = self.view.safeAreaLayoutGuide
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        picoLogoImageView.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(110)
            make.leading.equalTo(50)
            make.trailing.equalTo(-50)
            make.height.equalTo(50)
        }
        
        signInButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.bottom.equalTo(signUpButton.snp.top).offset(-20)
            make.height.equalTo(signUpButton.snp.height)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.bottom.equalTo(safeArea).offset(-80)
            make.height.equalTo(50)
        }
    }
}
