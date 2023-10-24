//
//  HomeFilterViewController.swift
//  Pico
//
//  Created by 임대진 on 2023/09/26.
//

import UIKit
import SnapKit

final class HomeFilterViewController: UIViewController {
    
    weak var homeViewController: HomeViewController?
    static var filterChangeState: Bool = false
    private let mbtiCollectionViewController = MBTICollectionViewController()
    private let ageSlider = RangeSlider()
    private let distanceSlider = UISlider()
    
    private let genderLabel: UILabel = {
        let label = UILabel()
        label.text = "상대 성별"
        label.font = .picoSubTitleFont
        return label
    }()
    
    private let genderSubLabel: UILabel = {
        let label = UILabel()
        label.text = "중복 선택 가능"
        label.font = .picoDescriptionFont
        return label
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.text = "거리"
        label.font = .picoSubTitleFont
        return label
    }()
    
    private let distanceValueLabel: UILabel = {
        let label = UILabel()
        label.font = .picoSubTitleFont
        return label
    }()
    
    private let mbtiLabel: UILabel = {
        let label = UILabel()
        label.text = "성격 유형"
        label.font = .picoSubTitleFont
        return label
    }()
    
    private let manButton: UIButton = {
        let button = UIButton()
        button.setTitle("남자", for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let womanButton: UIButton = {
        let button = UIButton()
        button.setTitle("여자", for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let etcButton: UIButton = {
        let button = UIButton()
        button.setTitle("기타", for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let genderHorizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 5
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let genderLabelVerticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()
    
    private let genderButtonHorizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 5
        stack.distribution = .fillEqually
        return stack
    }()
    
    override func viewDidLoad() {
        navigationItem.title = "선호 설정"
        tabBarController?.tabBar.isHidden = true
        view.configBackgroundColor()
        addSubView()
        makeConstraints()
        configUI()
        configButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if HomeFilterViewController.filterChangeState == true {
            self.homeViewController?.reloadView()
            HomeFilterViewController.filterChangeState = false
        }
    }
    
    private func configButton() {
        [manButton, womanButton, etcButton].forEach { button in
            button.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
        }
        manButton.isSelected = HomeViewModel.filterGender.contains(.male)
        updateButtonAppearance(manButton)
        
        womanButton.isSelected = HomeViewModel.filterGender.contains(.female)
        updateButtonAppearance(womanButton)
        
        etcButton.isSelected = HomeViewModel.filterGender.contains(.etc)
        updateButtonAppearance(etcButton)
    }
    
    private func configUI() {
        distanceSlider.maximumTrackTintColor = UIColor.lightGray.withAlphaComponent(0.5)
        distanceSlider.minimumTrackTintColor = .picoBlue
        distanceSlider.maximumValue = 501
        distanceSlider.value = Float(HomeViewModel.filterDistance)
        distanceSlider.addTarget(self, action: #selector(distanceSliderValueChanged), for: .valueChanged)
        if let thumbImage = UIImage(systemName: "circle.fill")?.withTintColor(.picoBlue) {
            let thumbSize = CGSize(width: 14, height: 14)
            let resizedThumbImage = thumbImage.resized(toSize: thumbSize)
            distanceSlider.setThumbImage(resizedThumbImage, for: .normal)
        }
        
        ageSlider.titleLabel.text = "나이"
        if HomeViewModel.filterDistance > 500 {
            distanceValueLabel.text = "0km ~ 500km +"
        } else {
            distanceValueLabel.text = "0km ~ \(HomeViewModel.filterDistance)km"
        }
        distanceValueLabel.textColor = .picoBlue
        distanceValueLabel.textAlignment = .right
    }
    
    private func addSubView() {
        view.addSubview([genderHorizontalStack, mbtiLabel, ageSlider, distanceSlider, distanceLabel, distanceValueLabel])
        
        genderHorizontalStack.addArrangedSubview([genderLabelVerticalStack, genderButtonHorizontalStack])
        genderLabelVerticalStack.addArrangedSubview([genderLabel, genderSubLabel])
        genderButtonHorizontalStack.addArrangedSubview([manButton, womanButton, etcButton])
        
        addChild(mbtiCollectionViewController)
        view.addSubview(mbtiCollectionViewController.view)
        mbtiCollectionViewController.didMove(toParent: self)
    }
    
    private func makeConstraints() {
        genderHorizontalStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(15)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-15)
            make.height.equalTo(40)
        }
        
        ageSlider.snp.makeConstraints { make in
            make.top.equalTo(genderHorizontalStack.snp.bottom).offset(45)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(15)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-15)
            make.bottom.equalTo(genderHorizontalStack.snp.bottom).offset(100)
        }
        
        distanceSlider.snp.makeConstraints { make in
            make.top.equalTo(ageSlider.snp.bottom).offset(25)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(15)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-15)
            make.bottom.equalTo(ageSlider.snp.bottom).offset(60)
        }
        
        distanceLabel.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(15)
            make.bottom.equalTo(distanceSlider.snp.centerY).offset(-15)
            make.width.equalTo(50)
            make.height.equalTo(30)
        }
        
        distanceValueLabel.snp.makeConstraints { make in
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-15)
            make.bottom.equalTo(distanceSlider.snp.centerY).offset(-15)
            make.width.equalTo(200)
            make.height.equalTo(30)
        }
        
        mbtiLabel.snp.makeConstraints { make in
            make.top.equalTo(distanceSlider.snp.bottom)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(15)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-15)
            make.height.equalTo(50)
        }
        
        mbtiCollectionViewController.view.snp.makeConstraints { make in
            make.top.equalTo(mbtiLabel.snp.bottom).offset(5)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(15)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-15)
            make.height.equalTo(mbtiCollectionViewController.view.frame.size.height)
        }
    }
    
    private func updateButtonAppearance(_ button: UIButton) {
        button.backgroundColor = button.isSelected ? .picoBlue : .picoGray
        button.setTitleColor(.white, for: .normal)
    }
    
    @objc func tappedButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        let genderType: GenderType?
        switch sender.currentTitle {
        case "남자":
            genderType = .male
        case "여자":
            genderType = .female
        case "기타":
            genderType = .etc
        default:
            genderType = nil
        }
        if let genderType = genderType {
            if sender.isSelected {
                HomeViewModel.filterGender.append(genderType)
                let genderData = try? JSONEncoder().encode(HomeViewModel.filterGender)
                UserDefaults.standard.set(genderData, forKey: UserDefaultsManager.Key.filterGender.rawValue)
            } else {
                if let index = HomeViewModel.filterGender.firstIndex(of: genderType) {
                    HomeViewModel.filterGender.remove(at: index)
                    let genderData = try? JSONEncoder().encode(HomeViewModel.filterGender)
                    UserDefaults.standard.set(genderData, forKey: UserDefaultsManager.Key.filterGender.rawValue)
                }
            }
            updateButtonAppearance(sender)
            HomeFilterViewController.filterChangeState = true
        }
    }
    
    @objc func distanceSliderValueChanged() {
        let selectedValue = Int(distanceSlider.value)
        HomeViewModel.filterDistance = selectedValue
        UserDefaults.standard.set(HomeViewModel.filterDistance, forKey: UserDefaultsManager.Key.filterDistance.rawValue)
        if selectedValue > 500 {
            distanceValueLabel.text = "0km ~ 500km +"
        } else {
            distanceValueLabel.text = "0km ~ \(selectedValue)km"
        }
    }
}
