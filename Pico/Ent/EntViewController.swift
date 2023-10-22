import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

final class EntViewController: BaseViewController {
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "gameBackground"))
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.7
        return imageView
    }()
    
    private let headerView: UIView = UIView()
    
    private let headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "banner")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let worldcupView: UIView = UIView()
    
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
        label.text = "마음에 드는 이성을 골라보세요!\n최종 선택 이성에게 채팅신청 시, 피코가 채팅 신청 비용의 50%를 부담해 드릴게요!"
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
        label.text = "24시간에 한 번만 진행 가능합니다"
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
        configTapGesture()
    }

    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    private func addViews() {
        view.addSubview([backgroundImageView, headerView, titleLabel, pickMeLabel, contentLabel, gameStartButton, guideLabel])
        headerView.addSubview(headerImageView)
    }
    
    private func makeConstraints() {
        let padding: CGFloat = 30
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(120)
        }
        
        headerImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerImageView.snp.bottom).offset(60)
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
                self.tappedGameStartButton()
            })
            .disposed(by: disposeBag)
    }
    
    private func checkGameAvailability() {
        if let lastStartedTime = UserDefaults.standard.object(forKey: "lastStartedTime") as? Date {
            let currentTime = Date()
            let timeInterval = currentTime.timeIntervalSince(lastStartedTime)
            let secondsIn24Hours: Double = 24 * 60 * 60
            
            if timeInterval < secondsIn24Hours {
                remainingTime = Int(secondsIn24Hours - timeInterval)
                startTimer()
                gameStartButton.isEnabled = false
            } else {
                gameStartButton.isEnabled = true
            }
        }
    }
    
    private func tappedGameStartButton() {
        let currentTime = Date()
        UserDefaults.standard.set(currentTime, forKey: "lastStartedTime")
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
            let hours = remainingTime / 3600
            let minutes = (remainingTime % 3600) / 60
            let seconds = remainingTime % 60
            guideLabel.text = String(format: "%02d시간 %02d분 %02d초 뒤에 다시 시작 가능합니다", hours, minutes, seconds)
        } else {
            gameStartButton.isEnabled = true
            timer?.invalidate()
            timer = nil
            guideLabel.text = "24시간에 한 번만 진행 가능합니다"
        }
    }
    
    private func configTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedHeaderView))
        headerView.addGestureRecognizer(tapGesture)
    }
    
    @objc func tappedHeaderView(_ sender: UITapGestureRecognizer) {
        let randomBoxViewController = RandomBoxViewController()
        self.navigationController?.pushViewController(randomBoxViewController, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
}
