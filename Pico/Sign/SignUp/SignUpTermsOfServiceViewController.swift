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
    private let locationVM = LocationManager()
    private let disposeBag = DisposeBag()
    private var isLoading: Bool = false
    private var isCheckedBottom: Bool = false
    private let termsOfServiceTexts: [String] = TermsOfServiceText.termsOfServiceTexts
    
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = .lightGray
        view.progressTintColor = .picoBlue
        view.layer.cornerRadius = SignView.progressViewCornerRadius
        view.layer.masksToBounds = true
        view.progress = viewModel.progressStatus
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
        view.configBackgroundColor()
        configNavigationBackButton()
        addSubViews()
        makeConstraints()
        configTableView()
        locationVM.configLocation()
        viewModel.isSaveSuccess
            .observe(on: MainScheduler.instance)
            .bind { [weak self] _ in
                print("저장완료")
                self?.navigationController?.popToRootViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    override func viewDidAppear(_ animated: Bool) {
        viewModel.animateProgressBar(progressView: progressView, endPoint: 7)
    }
}
// MARK: - Config
extension SignUpTermsOfServiceViewController {
    private func configTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
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
        // 위도 경도
        let space = locationVM.locationManager.location?.coordinate
        let lat = space?.latitude
        let long = space?.longitude
        
        locationVM.getAddress(latitude: lat, longitude: long) { [weak self] location in
            guard let self = self else {
                return
            }
            
            if let location = location {
                self.viewModel.locationSubject.onNext(location)
            } else {
                self.locationVM.accessLocation()
            }
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
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(notifyLabel.snp.bottom).offset(SignView.contentPadding)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(nextButton.snp.top).offset(-SignView.padding)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.equalTo(notifyLabel.snp.leading)
            make.trailing.equalTo(notifyLabel.snp.trailing)
            make.bottom.equalTo(safeArea).offset(SignView.bottomPadding)
            make.height.equalTo(CommonConstraints.buttonHeight)
        }
    }
}
