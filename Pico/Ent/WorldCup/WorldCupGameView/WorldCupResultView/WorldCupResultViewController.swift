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
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "gameBackground"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
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
        label.text = "채팅 신청 비용 50츄 (50%)"
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
        configRxBinding()
    }
    
    private func addViews() {
        [backgroundImageView, worldCupTitleLabel, pickMeLabel, contentLabel, resultUserView, chatButton, guideLabel, cancelButton].forEach { item in
            view.addSubview(item)
        }
    }
    
    private func makeConstraints() {
        let padding: CGFloat = 20
        let half: CGFloat = 0.5
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
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
    
    private func configRxBinding() {
        chatButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.tappedChatButton()
            })
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.tappedCancelButton()
            })
            .disposed(by: disposeBag)
    }
    
    private func tappedChatButton() {
        let customPopup = CustomPopupViewController()
        customPopup.alertType = .canCancel
        customPopup.titleText = "채팅 신청"
        customPopup.messageText = "이상형 월드컵 우승자와 매칭 시 매칭 성공률이 높아집니다!"
        customPopup.confirmButtonText = "신청"
        customPopup.cancelButtonText = "취소"
        
        customPopup.confirmAction = { [weak self] in
            if let navigationController = self?.navigationController {
                navigationController.popToRootViewController(animated: true)
            } else {
                self?.dismiss(animated: true, completion: nil)
            }
        }
        
        customPopup.cancelAction = {
            customPopup.dismiss(animated: true, completion: nil)
        }
        
        customPopup.modalPresentationStyle = .overFullScreen
        present(customPopup, animated: true, completion: nil)
    }

    private func tappedCancelButton() {
        let customPopup = CustomPopupViewController()
        customPopup.alertType = .canCancel
        customPopup.titleText = "신청하지 않고 나가기"
        customPopup.messageText = "매칭 성공률이 높은 상대가 채팅 신청을 기다리고 있습니다"
        customPopup.confirmButtonText = "나가기"
        customPopup.cancelButtonText = "취소"
        
        customPopup.confirmAction = { [weak self] in
            if let navigationController = self?.navigationController {
                navigationController.popToRootViewController(animated: true)
            } else {
                self?.dismiss(animated: true, completion: nil)
            }
        }
        
        customPopup.cancelAction = {
            customPopup.dismiss(animated: true, completion: nil)
        }
        
        customPopup.modalPresentationStyle = .overFullScreen
        present(customPopup, animated: true, completion: nil)
    }
}
