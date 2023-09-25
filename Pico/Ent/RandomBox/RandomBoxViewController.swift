//
//  RandomBoxViewController.swift
//  Pico
//
//  Created by 오영석 on 2023/09/25.
//

import UIKit
import SnapKit

final class RandomBoxViewController: UIViewController {
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "WorldCup"))
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    private let purchaseChuButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "chu"), for: .normal)
        button.contentMode = .scaleAspectFit
        //        button.addTarget(self, action: #selector(chuButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private let infoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "info.circle"), for: .normal)
        button.contentMode = .scaleAspectFill
        //        button.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        
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
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "랜덤박스를 열어 부족한 츄를 획득해보세요!\n꽝은 절대 없다!\n최대 100츄 획득의 기회를 놓치지 마세요!"
        label.numberOfLines = 0
        label.textColor = .black
        
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
        view.backgroundColor = .white
        addViews()
        makeConstraints()
        self.openOneBoxButton.addTarget(self, action: #selector(openBoxButtonTapped), for: .touchUpInside)
        self.openTenBoxButton.addTarget(self, action: #selector(openTenBoxButtonTapped), for: .touchUpInside)
    }
    
    private func addViews() {
        [backgroundImageView, purchaseChuButton, infoButton, randomBoxTitleLabel, contentLabel, randomBoxImage, openOneBoxButton, openTenBoxButton].forEach { item in
            view.addSubview(item)
        }
    }
    
    private func makeConstraints() {
        let padding: CGFloat = 20
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        purchaseChuButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(padding * 4)
            make.trailing.equalTo(infoButton.snp.leading).offset(-padding)
            make.width.height.equalTo(padding * 2)
        }
        
        infoButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(padding * 4)
            make.trailing.equalToSuperview().offset(-padding)
            make.width.height.equalTo(padding * 2)
        }
        
        randomBoxTitleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(Screen.width / 2)
            make.top.equalTo(infoButton.snp.bottom).offset(Screen.height / 12)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.centerX.equalTo(Screen.width / 2)
            make.top.equalTo(randomBoxTitleLabel.snp.bottom).offset(padding)
        }
        
        randomBoxImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(contentLabel.snp.bottom).offset(padding)
            make.height.equalTo(Screen.height / 3)
            make.width.equalTo(randomBoxImage.snp.height)
        }
        
        openOneBoxButton.snp.makeConstraints { make in
            make.top.equalTo(randomBoxImage.snp.bottom).offset(padding)
            make.width.equalTo(Screen.width / 2 - padding * 2)
            make.height.equalTo(padding * 2)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(padding)
        }
        
        openTenBoxButton.snp.makeConstraints { make in
            make.top.equalTo(randomBoxImage.snp.bottom).offset(padding)
            make.width.equalTo(Screen.width / 2 - padding * 2)
            make.height.equalTo(padding * 2)
            make.leading.equalTo(openOneBoxButton.snp.trailing).offset(padding)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-padding)
        }
    }
    
    @objc func openBoxButtonTapped() {
        self.openOneBoxButton.isEnabled = false
        self.openTenBoxButton.isEnabled = false
        
        self.randomBoxImage.shake {
            let randomValue = getRandomValue()
            self.updateCoin(with: Double(randomValue), number: 1)
            self.showAlert(with: randomValue)
            
            self.openOneBoxButton.isEnabled = true
            self.openTenBoxButton.isEnabled = true
        }
    }
    
    @objc func openTenBoxButtonTapped() {
        var boxHistory: [Int] = []
        
        self.openOneBoxButton.isEnabled = false
        self.openTenBoxButton.isEnabled = false
        
        self.randomBoxImage.shake {
            for _ in 0 ..< 10 {
                let randomValue = getRandomValue()
                self.updateCoin(with: Double(randomValue), number: 10)
                boxHistory.append(randomValue)
            }
            
            let sumBoxHistory = boxHistory.reduce(0, +)
            
            self.showAlert(with: sumBoxHistory)
            
            self.openOneBoxButton.isEnabled = true
            self.openTenBoxButton.isEnabled = true
        }
    }
    
    private func updateCoin(with randomValue: Double, number: Int) {
        _ = Int(randomValue)
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
}

extension UIView {
    func shake(duration: CFTimeInterval = 0.3, repeatCount: Float = 3, completion: (() -> Void)? = nil) {
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.duration = duration
        animation.values = [-0.15, 0.15, -0.15]
        animation.repeatCount = repeatCount
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?()
        }
        
        self.layer.add(animation, forKey: "shake")
        
        CATransaction.commit()
    }
}
