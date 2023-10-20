//
//  RandomBoxViewController.swift
//  Pico
//
//  Created by 오영석 on 2023/09/25.
//
import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class RandomBoxViewController: UIViewController {
    
    private let randomBoxManager = RandomBoxManager()
    let disposeBag = DisposeBag()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "gameBackground"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let purchaseChuButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "chu"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    private let infoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "info.circle"), for: .normal)
        button.contentMode = .scaleAspectFill
        return button
    }()
    
    private let randomBoxTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 36)
        label.text = "Random Box"
        label.textColor = .picoBlue
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.picoSubTitleFont
        label.text = "랜덤박스를 열어 부족한 츄를 획득해보세요!\n꽝은 절대 없다!\n최대 100츄 획득의 기회를 놓치지 마세요!"
        label.numberOfLines = 0
        return label
    }()
    
    private let randomBoxImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "chu")
        imageView.contentMode = .scaleAspectFit
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        return imageView
    }()
    
    private let openOneBoxButton: CommonButton = {
        let button = CommonButton()
        button.setTitle("1개 열기", for: .normal)
        return button
    }()
    
    private let openTenBoxButton: CommonButton = {
        let button = CommonButton()
        button.setTitle("10개 열기", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.configBackgroundColor()
        configNavigationBackButton()
        addViews()
        makeConstraints()
        configRxBinding()
        bind()
    }
    
    private func addViews() {
        [backgroundImageView, purchaseChuButton, infoButton, randomBoxTitleLabel, contentLabel, randomBoxImage, openOneBoxButton, openTenBoxButton].forEach { item in
            view.addSubview(item)
        }
    }
    
    private func makeConstraints() {
        let padding: CGFloat = 20
        let half: CGFloat = 0.5
        let buttonWidth: CGFloat = Screen.width / 2 - padding - 10
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        purchaseChuButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.trailing.equalTo(infoButton.snp.leading).offset(-padding * half)
            make.width.height.equalTo(padding * 2)
        }
        
        infoButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.trailing.equalToSuperview().offset(-padding * half)
            make.width.height.equalTo(padding * 2)
        }
        
        randomBoxTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(infoButton.snp.bottom).offset(Screen.height / 12)
            make.centerX.equalToSuperview()
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(randomBoxTitleLabel.snp.bottom).offset(padding)
            make.centerX.equalToSuperview()
        }
        
        randomBoxImage.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(padding)
            make.centerX.equalToSuperview()
            make.width.equalTo(randomBoxImage.snp.height)
            make.height.equalTo(Screen.height / 3)
        }
        
        openOneBoxButton.snp.makeConstraints { make in
            make.top.equalTo(randomBoxImage.snp.bottom).offset(padding)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(padding)
            make.trailing.equalTo(openTenBoxButton.snp.leading).offset(-padding)
            make.width.equalTo(buttonWidth)
            make.height.equalTo(padding * 2)
        }
        
        openTenBoxButton.snp.makeConstraints { make in
            make.top.equalTo(randomBoxImage.snp.bottom).offset(padding)
            make.leading.equalTo(openOneBoxButton.snp.trailing).offset(padding)
            make.width.equalTo(buttonWidth)
            make.height.equalTo(padding * 2)
        }
    }
    
    private func configRxBinding() {
        openOneBoxButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.tappedBoxButton()
            })
            .disposed(by: disposeBag)
        
        openTenBoxButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.tappedTenBoxButton()
            })
            .disposed(by: disposeBag)
    }
    
    private func tappedBoxButton() {
        guard UserDefaultsManager.shared.getChuCount() >= 1 else {
            showNotEnoughChuAlert()
            return
        }
        
        self.openOneBoxButton.isEnabled = false
        self.openTenBoxButton.isEnabled = false
        
        randomBoxManager.shake(view: self.randomBoxImage) {
            let randomValue = self.randomBoxManager.getRandomValue()
            self.randomBoxManager.obtainChu(with: randomValue, number: 1) // Update the obtained chu
            self.showAlert(with: randomValue)
            
            let updatedChuCount = UserDefaultsManager.shared.getChuCount() - 1
            UserDefaultsManager.shared.updateChuCount(updatedChuCount) // Update the chu count in UserDefaults
            
            self.openOneBoxButton.isEnabled = true
            self.openTenBoxButton.isEnabled = true
        }
    }
    
    private func tappedTenBoxButton() {
        guard UserDefaultsManager.shared.getChuCount() >= 10 else {
            showNotEnoughChuAlert()
            return
        }
        
        var boxHistory: [Int] = []
        
        self.openOneBoxButton.isEnabled = false
        self.openTenBoxButton.isEnabled = false
        
        randomBoxManager.shake(view: self.randomBoxImage) {
            for _ in 0 ..< 10 {
                let randomValue = self.randomBoxManager.getRandomValue()
                boxHistory.append(randomValue)
            }
            
            let sumBoxHistory = boxHistory.reduce(0, +)
            self.randomBoxManager.obtainChu(with: sumBoxHistory, number: 10) // Update the obtained chu
            
            let updatedChuCount = UserDefaultsManager.shared.getChuCount() - 10
            UserDefaultsManager.shared.updateChuCount(updatedChuCount) // Update the chu count in UserDefaults
            
            self.showAlert(with: sumBoxHistory)
            
            self.openOneBoxButton.isEnabled = true
            self.openTenBoxButton.isEnabled = true
        }
    }
    
    private func showAlert(with message: Int) {
        var messageSting: String = ""
        
        if message > 0 {
            messageSting = "+\(message)"
        } else {
            messageSting = "\(message)"
        }
        
        let alert = UIAlertController(title: nil, message: messageSting, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showNotEnoughChuAlert() {
        let alert = UIAlertController(title: "츄 부족", message: "츄가 부족합니다. 더 구매하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "구매하기", style: .default) { _ in
            let storeViewController = StoreViewController(viewModel: StoreViewModel())
            self.navigationController?.pushViewController(storeViewController, animated: true)
        })
        
        present(alert, animated: true, completion: nil)
    }
}

extension RandomBoxViewController {
    private func bind() {
        infoButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let messageText = self.randomBoxManager.getChuAndPercent()
                showCustomAlert(alertType: .onlyConfirm, titleText: "확률 정보", messageText: messageText, confirmButtonText: "닫기", comfrimAction: {
                    self.dismiss(animated: true, completion: nil)
                })
            })
            .disposed(by: disposeBag)
        
        purchaseChuButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let storeViewController = StoreViewController(viewModel: StoreViewModel())
                self.navigationController?.pushViewController(storeViewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        openOneBoxButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { viewController, _ in
                if UserDefaultsManager.shared.getChuCount() < 10 {
                    self.showCustomAlert(alertType: .canCancel, titleText: "보유 츄 부족", messageText: "보유하고 있는 츄가 부족합니다. \n현재 츄 : \(UserDefaultsManager.shared.getChuCount()) 개", cancelButtonText: "보내기 취소", confirmButtonText: "스토어로 이동", comfrimAction: {
                        let storeViewController = StoreViewController(viewModel: StoreViewModel())
                        self.navigationController?.pushViewController(storeViewController, animated: true)
                    })
                } else {
                    self.showCustomAlert(alertType: .canCancel, titleText: "중급 박스", messageText: "중급 박스를 구매합니다", cancelButtonText: "취소", confirmButtonText: "구매하기", comfrimAction: {
                        self.tappedBoxButton()
                    })
                }
            })
            .disposed(by: disposeBag)
        
        openTenBoxButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { viewController, _ in
                if UserDefaultsManager.shared.getChuCount() < 10 {
                    self.showCustomAlert(alertType: .canCancel, titleText: "보유 츄 부족", messageText: "보유하고 있는 츄가 부족합니다. \n현재 츄 : \(UserDefaultsManager.shared.getChuCount()) 개", cancelButtonText: "보내기 취소", confirmButtonText: "스토어로 이동", comfrimAction: {
                        let storeViewController = StoreViewController(viewModel: StoreViewModel())
                        self.navigationController?.pushViewController(storeViewController, animated: true)
                    })
                } else {
                    self.showCustomAlert(alertType: .canCancel, titleText: "고급 박스", messageText: "중급 박스를 구매합니다", cancelButtonText: "취소", confirmButtonText: "구매하기", comfrimAction: {
                        self.tappedBoxButton()
                    })
                }
            })
            .disposed(by: disposeBag)
    }
}
