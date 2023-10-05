//
//  SignUpTermsOfServiceViewController.swift
//  Pico
//
//  Created by LJh on 2023/09/27.
//

import UIKit
import SnapKit
import CoreLocation
import Foundation

class LocationService {
    
    static var shared = LocationService()
    var longitude: Double!
    var latitude: Double!
  
}
final class SignUpTermsOfServiceViewController: UIViewController {
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D!
    
    private var isLoading: Bool = false
    private var isCheckedBottom: Bool = false
    private let termsOfServiceTexts: [String] = TermsOfServiceText.termsOfServiceTexts
    
    private let progressView: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = .picoBetaBlue
        view.progressTintColor = .picoBlue
        view.progress = 0.142 * 7
        view.layer.cornerRadius = Constraint.SignView.progressViewCornerRadius
        view.layer.masksToBounds = true
        return view
    }()
    
    private let notifyLabel: UILabel = {
        let label = UILabel()
        label.text = "이용약관에 동의해주세요"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.picoTitleFont
        return label
    }()
    
    private lazy var nextButton: UIButton = {
        let button = CommonButton(type: .custom)
        button.setTitle("완료", for: .normal)
        button.backgroundColor = .picoGray
        button.addTarget(self, action: #selector(tappedNextButton), for: .touchUpInside)
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .picoAlphaWhite
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configBackButton()
        addSubViews()
        makeConstraints()
        configTableView()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

    }
}
// MARK: - Config
extension SignUpTermsOfServiceViewController {
    private func configTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    // MARK: - @objc
    @objc private func tappedNextButton(_ sender: UIButton) {
        requestAuthorizqtion()
//        print("""
//              mbti:\(SignUpViewModel.userMbti),
//              === number: \(SignUpViewModel.phoneNumber),
//              birth: \(SignUpViewModel.birth),
//              === gender: \(SignUpViewModel.gender),
//              nickname: \(SignUpViewModel.nickName),
//              === imageURL \(SignUpViewModel.imageURLs)
//              """)
//        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - 위치관련
extension SignUpTermsOfServiceViewController: CLLocationManagerDelegate {
//    private func requestAuthorization() {
//        if locationManager != nil {
//            locationManager = CLLocationManager()
//            // 정확도를 검사한다.
//            locationManager.desiredAccuracy = kCLLocationAccuracyBest
//            // 앱을 사용할때 권한요청
//            locationManager.requestWhenInUseAuthorization()
//            locationManager.delegate = self
//            locationManagerDidChangeAuthorization(locationManager)
//            print("if")
//        } else {
//            // 사용자의 위치가 바뀌고 있는지 확인하는 메소드
//            locationManager.startMonitoringSignificantLocationChanges()
//            print("else")
//        }
//    }
    // 사용자가 위치 서비스에 대한 권한을 변경할 때마다 이 메서드가 호출
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            if manager.authorizationStatus == .authorizedWhenInUse {
                currentLocation = locationManager.location?.coordinate
                LocationService.shared.longitude = currentLocation.longitude
                LocationService.shared.latitude = currentLocation.latitude
            } else {
                print("ㅎㅎ")
            }
        }
    func requestAuthorizqtion() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("autjo")
//                    moveFocusOnUserLocation()
        case .notDetermined:
            print("2notDetermined")
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
        default:
            print("s \(locationManager.authorizationStatus)")
            break
        }
    }
}

// MARK: - tableView관련
extension SignUpTermsOfServiceViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return termsOfServiceTexts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = termsOfServiceTexts[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    func updateNextButton(isCheck: Bool) {
        switch isCheck {
        case true:
            nextButton.isEnabled = true
            nextButton.backgroundColor = .picoBlue
        case false:
            nextButton.isEnabled = false
            nextButton.backgroundColor = .picoGray
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        isLoading = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard isLoading else { return }
        let isAtBottom = scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)
        guard !isCheckedBottom else { return }
        isCheckedBottom = isAtBottom ? true : false
        updateNextButton(isCheck: isCheckedBottom)
    }
}

// MARK: - UI관련
extension SignUpTermsOfServiceViewController {
    private func addSubViews() {
        for viewItem in [progressView, notifyLabel, nextButton, tableView] {
            view.addSubview(viewItem)
        }
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(Constraint.SignView.progressViewTopPadding)
            make.leading.equalTo(Constraint.SignView.padding)
            make.trailing.equalTo(-Constraint.SignView.padding)
            make.height.equalTo(8)
        }
        
        notifyLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(Constraint.SignView.padding)
            make.leading.equalTo(Constraint.SignView.padding)
            make.trailing.equalTo(-Constraint.SignView.padding)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(notifyLabel.snp.bottom).offset(Constraint.SignView.contentPadding)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(nextButton.snp.top).offset(-Constraint.SignView.padding)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.equalTo(notifyLabel.snp.leading)
            make.trailing.equalTo(notifyLabel.snp.trailing)
            make.bottom.equalTo(safeArea).offset(Constraint.SignView.bottomPadding)
            make.height.equalTo(Constraint.Button.commonHeight)
        }
    }
}
