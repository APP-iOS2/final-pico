//
//  WorldCupResultViewController.swift
//  Pico
//
//  Created by 오영석 on 2023/10/04.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class WorldCupResultViewController: UIViewController {
    
    var selectedItem: User?
    private let disposeBag = DisposeBag()
    private let viewModel = WorldCupResultViewModel()
    private let requestMessagePublisher = PublishSubject<User>()

    private let worldCupTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 36)
        label.text = "이상형 월드컵"
        return label
    }()
    
    private let pickMeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.picoTitleFont
        label.text = "우승"
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.picoButtonFont
        label.textColor = .picoFontGray
        label.text = "농치기 아쉽다면?\n채팅을 신청해보세요!"
        label.numberOfLines = 0
        return label
    }()
    
    private let resultUserView: ResultUserView = {
        let view = ResultUserView()
        return view
    }()
    
    private lazy var chatButton: CommonButton = {
        let button = CommonButton()
        button.setTitle("채팅 신청하기", for: .normal)
        return button
    }()
    
    private let guideLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.picoEntSubLabelFont
        label.text = "채팅 신청 비용 25츄 (50%)"
        label.textColor = .picoFontGray
        return label
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("채팅 신청하지 않고 나가기", for: .normal)
        button.setTitleColor(.picoAlphaBlue, for: .normal)
        button.titleLabel?.font = UIFont.picoButtonFont
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.configBackgroundColor()
        hideNavigationBackButton()
        addViews()
        makeConstraints()
        configResultUserCell()
        addShadow()
        bind()
    }
    
    private func addViews() {
        view.addSubview([worldCupTitleLabel, pickMeLabel, contentLabel, resultUserView, chatButton, guideLabel, cancelButton])
    }
    
    private func makeConstraints() {
        let padding: CGFloat = 20
        let half: CGFloat = 0.5
        
        worldCupTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Screen.height / 8)
            make.centerX.equalToSuperview().offset(half)
        }
        
        pickMeLabel.snp.makeConstraints { make in
            make.top.equalTo(worldCupTitleLabel.snp.bottom).offset(padding * half)
            make.centerX.equalToSuperview().offset(half)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(pickMeLabel.snp.bottom).offset(padding * half)
            make.centerX.equalToSuperview().offset(half)
        }
        
        resultUserView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(padding * 2)
            make.centerX.equalToSuperview()
            make.width.equalTo(Screen.width * 0.5)
            make.height.equalTo(Screen.height * 0.5)
        }
        
        chatButton.snp.makeConstraints { make in
            make.top.equalTo(resultUserView.userAge.snp.bottom).offset(padding)
            make.centerX.equalToSuperview().offset(half)
            make.leading.equalToSuperview().offset(Screen.width / 3.5)
            make.trailing.equalToSuperview().offset(-Screen.width / 3.5)
            make.height.equalTo(Screen.width / 10)
        }
        
        guideLabel.snp.makeConstraints { make in
            make.top.equalTo(chatButton.snp.bottom).offset(padding * half)
            make.centerX.equalToSuperview()
        }
        
        cancelButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(0.5)
            make.bottom.equalToSuperview().offset(-padding * 1.5)
        }
    }
    
    private func configResultUserCell() {
        if let selectedItem = selectedItem {
            resultUserView.mbtiLabel.setMbti(mbti: selectedItem.mbti)
            resultUserView.userNickname.text = String(selectedItem.nickName)
            resultUserView.userAge.text = "\(selectedItem.age)세"
            
            if let imageURL = selectedItem.imageURLs.first, let url = URL(string: imageURL) {
                resultUserView.userImage.load(url: url)
            }
        }
    }

    private func addShadow(opacity: Float = 0.07, radius: CGFloat = 5.0) {
        resultUserView.layer.masksToBounds = false
        resultUserView.layer.shadowColor = UIColor.black.cgColor
        resultUserView.layer.shadowOffset = CGSize(width: 10, height: 10)
        resultUserView.layer.shadowOpacity = opacity
        resultUserView.layer.shadowRadius = radius
    }
}

extension WorldCupResultViewController {
    private func bind() {
        chatButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { viewController, _ in
                if UserDefaultsManager.shared.getChuCount() <= 25 {
                    viewController.showCustomAlert(alertType: .canCancel, titleText: "보유 츄 부족", messageText: "보유하고 있는 츄가 부족합니다. \n현재 츄 : \(UserDefaultsManager.shared.getChuCount()) 개", cancelButtonText: "보내기 취소", confirmButtonText: "스토어로 이동", comfrimAction: {
                        let storeViewController = StoreViewController(viewModel: StoreViewModel())
                        viewController.navigationController?.pushViewController(storeViewController, animated: true)
                    })
                } else {
                    guard let resultUser = viewController.selectedItem else { return }
                    viewController.showCustomAlert(alertType: .canCancel, titleText: "쪽지 신청", messageText: "월드컵 우승자에게 쪽지를 보낼 시 50% 할인된 가격으로 보낼 수 있습니다!", confirmButtonText: "신청", comfrimAction: {
                        viewController.requestMessagePublisher.onNext(resultUser)
                    })
                }
            })
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                showCustomAlert(alertType: .canCancel, titleText: "신청하지 않고 나가기", messageText: "이 페이지에서만 50% 할인된 가격으로 신청할 수 있습니다.", confirmButtonText: "나가기", comfrimAction: {
                    if let navigationController = self.navigationController {
                        navigationController.popToRootViewController(animated: true)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            })
            .disposed(by: disposeBag)
        
        let input = WorldCupResultViewModel.Input(requestMessage: requestMessagePublisher.asObservable())
        let output = viewModel.transform(input: input)
        
        output.resultRequestMessage
            .withUnretained(self)
            .subscribe { viewController, _ in
                viewController.showCustomAlert(alertType: .onlyConfirm, titleText: "쪽지 요청 성공", messageText: "받은 메일함을 확인해 주세요.", confirmButtonText: "확인", comfrimAction: {
                    if let navigationController = self.navigationController {
                        navigationController.popToRootViewController(animated: true)
                    } else {
                        self.dismiss(animated: true)
                    }
                })
            }
            .disposed(by: disposeBag)
    }
}
