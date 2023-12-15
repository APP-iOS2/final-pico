//
//  WorldCupGameViewController.swift
//  Pico
//
//  Created by 오영석 on 2023/09/25.
//
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

final class EntViewController: BaseViewController {
    private let viewModel = WorldCupViewModel()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "gameBackground"))
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.7
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.picoTitleFont
        label.text = "당신의 친구에게 투표하세요"
        return label
    }()
    
    private let pickMeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .picoGameTitleFont
        label.text = "Pick Me"
        label.textColor = .picoBlue
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.text = "마음에 드는 친구를 골라보세요!\n최종 선택 친구에게 쪽지신청 시, 피코가 쪽지 신청 비용의 50%를 부담해 드릴게요!"
        label.numberOfLines = 0
        label.setLineSpacing(spacing: 10)
        label.textAlignment = .center
        return label
    }()
    
    private let gameStartButton: CommonButton = {
        let button = CommonButton()
        button.setTitle("시작", for: .normal)
        return button
    }()
    
    private let guideLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .picoFontGray
        label.font = .picoDescriptionFont
        label.text = "30분에 한 번만 진행 가능합니다"
        return label
    }()
    
    private let disposeBag = DisposeBag()
    
    private var timer: Timer?
    private var remainingTime: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavigationBackButton()
        addViews()
        makeConstraints()
        configRxBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadUsersRx()
        checkGameAvailability()
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    private func addViews() {
        view.addSubview([backgroundImageView, titleLabel, pickMeLabel, contentLabel, gameStartButton, guideLabel])
    }
    
    private func makeConstraints() {
        let padding: CGFloat = 30
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(60)
            make.leading.equalToSuperview().offset(45)
            make.trailing.equalToSuperview().offset(-45)
        }
        
        pickMeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(padding)
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalTo(titleLabel.snp.trailing)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(pickMeLabel.snp.bottom).offset(padding)
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalTo(titleLabel.snp.trailing)
        }
        
        gameStartButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Screen.width * 0.2)
            make.trailing.equalToSuperview().offset(-Screen.width * 0.2)
            make.height.equalTo(40)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-80)
        }
        
        guideLabel.snp.makeConstraints { make in
            make.top.equalTo(gameStartButton.snp.bottom).offset(15)
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalTo(titleLabel.snp.trailing)
        }
    }
    
    private func configRxBinding() {
        gameStartButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                if viewModel.checkStart() {
                    tappedGameStartButton()
                } else {
                    showCustomAlert(alertType: .onlyConfirm, titleText: "준비중", messageText: "가입자 수가 부족하여 아직 게임을 진행할 수 없습니다.", confirmButtonText: "확인")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func checkGameAvailability() {
        if let lastStartedTime = UserDefaultsManager.shared.getLastWorldCupTime() {
            let currentTime = Date()
            let timeInterval = currentTime.timeIntervalSince(lastStartedTime)
            let secondsForHalf: Double = 30 * 60

            if timeInterval < secondsForHalf {
                remainingTime = Int(secondsForHalf - timeInterval)
                gameStartButton.isEnabled = false
                startTimer()
            } else {
                gameStartButton.isEnabled = true
            }
        }
    }
    
    private func tappedGameStartButton() {
        let currentTime = Date()
        UserDefaultsManager.shared.updateLastWorldCupTime(currentTime)
        if let navigationController = self.navigationController {
            navigationController.pushViewController(WorldCupGameViewController(), animated: true)
            self.tabBarController?.tabBar.isHidden = true
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    @objc private func updateTimer() {
        remainingTime -= 1
        
        if remainingTime > 0 {
            let minutes = remainingTime / 60
            let seconds = remainingTime % 60

            DispatchQueue.main.async {
                self.guideLabel.text = String(format: "%02d분 %02d초 뒤에 다시 시작 가능합니다", minutes, seconds)
            }
        } else {
            DispatchQueue.main.async {
                self.gameStartButton.isEnabled = true
                self.timer?.invalidate()
                self.timer = nil
                self.guideLabel.text = "30분에 한 번만 진행 가능합니다"
            }
        }
    }
}
