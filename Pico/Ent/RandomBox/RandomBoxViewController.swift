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
import Lottie

final class RandomBoxViewController: UIViewController {
    
    private let randomBoxViewModel = RandomBoxViewModel()
    private let normalPaymentPublisher = PublishSubject<Int>()
    private let advancedPaymentPublisher = PublishSubject<Int>()
    private let obtainChuPublisher = PublishSubject<Int>()
    private let disposeBag = DisposeBag()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "gameBackground"))
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.7
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .picoGameTitleFont
        label.text = "Random Box"
        label.textColor = .picoBlue
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.text = "랜덤박스를 열어 부족한 츄를 획득해보세요!\n꽝은 절대 없다!\n최대 100츄 획득의 기회를 놓치지 마세요!"
        label.numberOfLines = 0
        label.setLineSpacing(spacing: 10)
        label.textAlignment = .center
        return label
    }()
    
    private let guidLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.picoDescriptionFont
        label.textColor = .picoFontGray
        label.text = "일반 뽑기는 10츄, 고급 뽑기는 30츄가 소모됩니다"
        label.setLineSpacing(spacing: 5)
        label.textAlignment = .center
        return label
    }()
    
    private let randomBoxImage: LottieAnimationView = LottieAnimationView(name: "randomBox")
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.picoLargeTitleFont
        label.textColor = .picoBlue
        label.text = "1"
        return label
    }()
    
    private let plusButton: UIButton = {
        let button = UIButton()
        button.setTitle("+", for: .normal)
        button.setTitleColor(.picoBlue, for: .normal)
        button.titleLabel?.font = UIFont.picoLargeTitleFont
        return button
    }()
    
    private let minusButton: UIButton = {
        let button = UIButton()
        button.setTitle("-", for: .normal)
        button.setTitleColor(.picoBlue, for: .normal)
        button.titleLabel?.font = UIFont.picoLargeTitleFont
        return button
    }()
    
    private let buttonView = UIView()
    
    private let normalBoxButton: CommonButton = {
        let button = CommonButton()
        button.setTitle("일반 상자 뽑기", for: .normal)
        return button
    }()
    
    private let advancedBoxButton: CommonButton = {
        let button = CommonButton()
        button.setTitle("고급 상자 뽑기", for: .normal)
        return button
    }()
    
    private let infoButton: UIButton = {
        let button = UIButton()
        button.setTitle("상품 정보 보기", for: .normal)
        button.setTitleColor(.picoBlue, for: .normal)
        button.titleLabel?.font = UIFont.picoDescriptionFont
        return button
    }()
    
    private let emitterLayer = CAEmitterLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.configBackgroundColor()
        configNavigationBackButton()
        addViews()
        makeConstraints()
        bind()
        configureEmitter()
    }
    
    private func addViews() {
        view.addSubview([backgroundImageView, titleLabel, contentLabel, guidLabel, randomBoxImage, countLabel, plusButton, minusButton, buttonView, infoButton])
        buttonView.addSubview([normalBoxButton, advancedBoxButton])
    }
    
    private func makeConstraints() {
        let padding: CGFloat = 20
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.centerX.equalToSuperview()
            make.height.equalTo(titleLabel.font.pointSize)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(padding)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(padding)
            make.height.equalTo(contentLabel.font.pointSize * 5)
        }
        
        guidLabel.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(padding)
            make.height.equalTo(guidLabel.font.pointSize)
        }
        
        randomBoxImage.snp.makeConstraints { make in
            make.top.equalTo(guidLabel.snp.bottom)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview().offset(padding)
            make.height.greaterThanOrEqualTo(Screen.height * 0.3).priority(.required)
        }

        countLabel.snp.makeConstraints { make in
            make.top.equalTo(randomBoxImage.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
        }
        
        plusButton.snp.makeConstraints { make in
            make.top.equalTo(countLabel)
            make.leading.equalTo(countLabel.snp.trailing)
            make.bottom.equalTo(countLabel)
            make.width.height.equalTo(30)
        }
        
        minusButton.snp.makeConstraints { make in
            make.top.equalTo(countLabel)
            make.trailing.equalTo(countLabel.snp.leading)
            make.bottom.equalTo(countLabel)
            make.width.height.equalTo(30)
        }
        
        buttonView.snp.makeConstraints { make in
            make.top.equalTo(countLabel.snp.bottom).offset(padding)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(padding * 2)
            make.height.equalTo(padding * 2)
        }
        
        normalBoxButton.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(advancedBoxButton.snp.leading).offset(-padding)
        }
        
        advancedBoxButton.snp.makeConstraints { make in
            make.top.trailing.bottom.equalToSuperview()
            make.width.equalTo(normalBoxButton.snp.width)
        }
        
        infoButton.snp.makeConstraints { make in
            make.top.equalTo(buttonView.snp.bottom).offset(10)
            make.centerX.equalTo(countLabel.snp.centerX)
            make.bottom.equalToSuperview().offset(-padding * 2)
            make.height.equalTo(infoButton.titleLabel?.font.pointSize ?? 20)
        }
    }
    
    private func increaseCount() {
        guard let currentQuantity = Int(countLabel.text ?? "0"), currentQuantity < 10 else { return }
        let newQuantity = currentQuantity + 1
        countLabel.text = "\(newQuantity)"
    }
    
    private func decreaseCount() {
        guard let currentQuantity = Int(countLabel.text ?? "0"), currentQuantity > 1 else { return }
        let newQuantity = currentQuantity - 1
        countLabel.text = "\(newQuantity)"
    }
    
    private func tappedNormalBox(count: Int) {
        var boxHistory: [Int] = []
        
        self.normalBoxButton.isEnabled = false
        self.advancedBoxButton.isEnabled = false
        
        randomBoxViewModel.shake(view: self.randomBoxImage) {
            for _ in 0 ..< count {
                let randomValue = self.randomBoxViewModel.getRandomValue(index: 1)
                boxHistory.append(randomValue)
            }
            
            let sumBoxHistory = boxHistory.reduce(0, +)
            self.obtainChuPublisher.onNext(sumBoxHistory)
        }
    }
    
    private func tappedAdvancedBox(count: Int) {
        var boxHistory: [Int] = []
        
        self.normalBoxButton.isEnabled = false
        self.advancedBoxButton.isEnabled = false
        
        randomBoxViewModel.shake(view: self.randomBoxImage) {
            for _ in 0 ..< count {
                let randomValue = self.randomBoxViewModel.getRandomValue(index: 1)
                boxHistory.append(randomValue)
            }
            
            let sumBoxHistory = boxHistory.reduce(0, +)
            self.obtainChuPublisher.onNext(sumBoxHistory)
        }
    }
    
    private func showAlert(with message: Int) {
        let messageSting: String = "\(message)"
        showCustomAlert(alertType: .onlyConfirm, titleText: "뽑기 결과", messageText: "\(messageSting)츄를 획득하셨습니다!", confirmButtonText: "닫기", comfrimAction: {
            self.dismiss(animated: true, completion: nil)
            self.countLabel.text = "1"
            DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                self?.emitterLayer.removeFromSuperlayer()
            }
        })
    }
    
    private func configureEmitter() {
        let cell = CAEmitterCell()
        cell.contents = UIImage(named: "chu")?.cgImage
        cell.lifetime = 3
        cell.birthRate = 20
        cell.scale = 0.15
        cell.scaleRange = 0.05
        cell.spin = 5
        cell.spinRange = 10
        cell.emissionRange = CGFloat.pi * 2
        cell.velocity = 300
        cell.velocityRange = 50
        cell.yAcceleration = 600
        
        emitterLayer.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        emitterLayer.emitterShape = .point
        emitterLayer.renderMode = .additive
        emitterLayer.emitterCells = [cell]
    }
    
    private func showParticleEffect() {
        view.layer.addSublayer(emitterLayer)
    }
}

extension RandomBoxViewController {
    private func bind() {
        let input = RandomBoxViewModel.Input(requestNormalPayment: normalPaymentPublisher, requestAdvancedPayment: advancedPaymentPublisher, obtainChu: obtainChuPublisher)
        let output = randomBoxViewModel.transform(input: input)
        
        output.resultNormal
            .withUnretained(self)
            .subscribe { viewController, _ in
                viewController.tappedNormalBox(count: Int(viewController.countLabel.text ?? "0") ?? 0)
            }
            .disposed(by: disposeBag)
        
        output.resultAdvanced
            .withUnretained(self)
            .subscribe { viewController, _ in
                viewController.tappedAdvancedBox(count: Int(viewController.countLabel.text ?? "0") ?? 0)
            }
            .disposed(by: disposeBag)
        
        output.resultObtainChu
            .withUnretained(self)
            .subscribe { viewController, _ in
                viewController.showAlert(with: viewController.randomBoxViewModel.obtainedChu)
                viewController.showParticleEffect()
                
                viewController.normalBoxButton.isEnabled = true
                viewController.advancedBoxButton.isEnabled = true
            }
            .disposed(by: disposeBag)
        
        infoButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let messageText = randomBoxViewModel.boxInfo()
                showCustomAlert(
                    alertType: .onlyConfirm,
                    titleText: "상자 구성품",
                    messageText: messageText,
                    confirmButtonText: "닫기",
                    comfrimAction: { [weak self] in
                        guard let self = self else { return }
                        dismiss(animated: true, completion: nil)
                    })
            })
            .disposed(by: disposeBag)
        
        normalBoxButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { viewController, _ in
                if let countText = viewController.countLabel.text, let count = Int(countText), UserDefaultsManager.shared.getChuCount() < (10 * count) {
                    viewController.showCustomAlert(
                        alertType: .canCancel,
                        titleText: "보유 츄 부족",
                        messageText: "보유하고 있는 츄가 부족합니다. \n현재 츄 : \(UserDefaultsManager.shared.getChuCount()) 개",
                        cancelButtonText: "취소",
                        confirmButtonText: "스토어로 이동",
                        comfrimAction: { [weak self] in
                            guard let self else { return }
                            let storeViewController = StoreViewController(viewModel: StoreViewModel())
                            navigationController?.pushViewController(storeViewController, animated: true)
                        })
                } else {
                    viewController.showCustomAlert(
                        alertType: .canCancel,
                        titleText: "일반 박스",
                        messageText: "보유 츄 : \(UserDefaultsManager.shared.getChuCount())\n\(10 * (Int(self.countLabel.text ?? "") ?? 1))츄를 사용하여\n일반 박스 \(self.countLabel.text ?? "1")개를 구매합니다",
                        cancelButtonText: "취소",
                        confirmButtonText: "구매하기",
                        comfrimAction: { [weak self] in
                            guard let self else { return }
                            normalPaymentPublisher.onNext(10 * (Int(self.countLabel.text ?? "") ?? 1))
                        })
                }
            })
            .disposed(by: disposeBag)
        
        advancedBoxButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { viewController, _ in
                if let countText = viewController.countLabel.text, let count = Int(countText), UserDefaultsManager.shared.getChuCount() < (30 * count) {
                    viewController.showCustomAlert(
                        alertType: .canCancel,
                        titleText: "보유 츄 부족",
                        messageText: "보유하고 있는 츄가 부족합니다. \n현재 츄 : \(UserDefaultsManager.shared.getChuCount()) 개",
                        cancelButtonText: "취소",
                        confirmButtonText: "스토어로 이동",
                        comfrimAction: { [weak self] in
                            guard let self else { return }
                            let storeViewController = StoreViewController(viewModel: StoreViewModel())
                            navigationController?.pushViewController(storeViewController, animated: true)
                        })
                } else {
                    viewController.showCustomAlert(
                        alertType: .canCancel,
                        titleText: "고급 박스",
                        messageText: "보유 츄 : \(UserDefaultsManager.shared.getChuCount())\n\(30 * (Int(viewController.countLabel.text ?? "") ?? 1))츄를 사용하여\n고급 박스 \(viewController.countLabel.text ?? "1")개를 구매합니다",
                        cancelButtonText: "취소",
                        confirmButtonText: "구매하기",
                        comfrimAction: { [weak self] in
                            guard let self else { return }
                            advancedPaymentPublisher.onNext(30 * (Int(self.countLabel.text ?? "") ?? 1))
                        })
                }
            })
            .disposed(by: disposeBag)
        
        plusButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.increaseCount()
            })
            .disposed(by: disposeBag)
        
        minusButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.decreaseCount()
            })
            .disposed(by: disposeBag)
    }
}
