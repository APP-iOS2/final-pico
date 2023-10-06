//
//  SignUpTermsOfServiceViewController.swift
//  Pico
//
//  Created by LJh on 2023/09/27.
//

import UIKit
import SnapKit
import CoreLocation

final class SignUpTermsOfServiceViewController: UIViewController {
    
    private var locationManager: CLLocationManager = CLLocationManager()
    private var currentLocation: CLLocationCoordinate2D?
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
        button.isEnabled = false
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        configLocation()
    }
}
// MARK: - Config
extension SignUpTermsOfServiceViewController {
    private func configTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    private func configLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        // 위도 경도
        let space = locationManager.location?.coordinate
        let lat = space?.latitude
        let long = space?.longitude
        getAddressFromCoordinates(latitude: lat, longitude: long)
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager.startUpdatingLocation()
            } else {
                print("이미 했잖아")
            }
        }
    }
    private func updateNextButton(isCheck: Bool) {
        switch isCheck {
        case true:
            nextButton.isEnabled = true
            nextButton.backgroundColor = .picoBlue
        case false:
            nextButton.isEnabled = false
            nextButton.backgroundColor = .picoGray
        }
    }
    // MARK: - @objc
    @objc private func tappedNextButton(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
}
// MARK: - 위치관련
extension SignUpTermsOfServiceViewController: CLLocationManagerDelegate {
    private func getAddressFromCoordinates(latitude: CLLocationDegrees?, longitude: CLLocationDegrees?) {
        let location = CLLocation(latitude: latitude ?? 0, longitude: longitude ?? 0)
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Geocoding Error: \(error)")
                return
            }
            if let placemark = placemarks?.first {
                let addressString = "\(placemark.thoroughfare ?? "") \(placemark.subThoroughfare ?? ""), \(placemark.locality ?? "") \(placemark.postalCode ?? ""), \(placemark.country ?? "")"
                SignUpViewModel.location = Location(address: addressString, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
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
