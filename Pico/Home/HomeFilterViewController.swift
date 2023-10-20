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
    private let mbtiCollectionViewController = MBTICollectionViewController()
    private lazy var genderLabel: UILabel = createFilterLabel(text: "상대 성별", font: .picoSubTitleFont)
    private lazy var genderSubLabel: UILabel = createFilterLabel(text: "중복 선택 가능", font: .picoDescriptionFont)
    private lazy var distanceLabel: UILabel = createFilterLabel(text: "거리", font: .picoSubTitleFont)
    private lazy var distanceValueLabel: UILabel = createFilterLabel(text: "0km ~ 200km", font: .picoSubTitleFont)
    private lazy var mbtiLabel: UILabel = createFilterLabel(text: "성격 유형", font: .picoSubTitleFont)
    private lazy var manButton: UIButton = createFilterButton(title: "남자")
    private lazy var womanButton: UIButton = createFilterButton(title: "여자")
    private lazy var etcButton: UIButton = createFilterButton(title: "기타")
    
    private let ageSlider = RangeSlider()
    private let distanceSlider = UISlider()
    
    // MARK: - 스택
    private lazy var genderHStack: UIStackView = createFilterStack(axis: .horizontal, spacing: 5, distribution: .fillEqually)
    private lazy var genderLabelVStack: UIStackView = createFilterStack(axis: .vertical, spacing: 0, distribution: nil)
    private lazy var genderButtonHStack: UIStackView = createFilterStack(axis: .horizontal, spacing: 5, distribution: .fillEqually)
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        navigationItem.title = "선호 설정"
        tabBarController?.tabBar.isHidden = true
        view.configBackgroundColor()
        addSubView()
        makeConstraints()
        configUI()
    }
    
    private func configUI() {
        ageSlider.titleLabel.text = "나이"
        
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
        
        if HomeViewModel.filterDistance > 500 {
            distanceValueLabel.text = "0km ~ 500km +"
        } else {
            distanceValueLabel.text = "0km ~ \(HomeViewModel.filterDistance)km"
        }
        distanceValueLabel.textColor = .picoBlue
        distanceValueLabel.textAlignment = .right
        
        manButton.isSelected = HomeViewModel.filterGender.contains(.male)
        updateButtonAppearance(manButton)
        
        womanButton.isSelected = HomeViewModel.filterGender.contains(.female)
        updateButtonAppearance(womanButton)
        
        etcButton.isSelected = HomeViewModel.filterGender.contains(.etc)
        updateButtonAppearance(etcButton)
    }
    
    private func addSubView() {
        view.addSubview([genderHStack, mbtiLabel, ageSlider, distanceSlider, distanceLabel, distanceValueLabel])
        
        genderHStack.addArrangedSubview(genderLabelVStack)
        genderHStack.addArrangedSubview(genderButtonHStack)
        genderLabelVStack.addArrangedSubview(genderLabel)
        genderLabelVStack.addArrangedSubview(genderSubLabel)
        genderButtonHStack.addArrangedSubview(manButton)
        genderButtonHStack.addArrangedSubview(womanButton)
        genderButtonHStack.addArrangedSubview(etcButton)
        
        addChild(mbtiCollectionViewController)
        view.addSubview(mbtiCollectionViewController.view)
        mbtiCollectionViewController.didMove(toParent: self)
    }
    
    private func makeConstraints() {
        genderHStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(15)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-15)
            make.height.equalTo(40)
        }
        
        ageSlider.snp.makeConstraints { make in
            make.top.equalTo(genderHStack.snp.bottom).offset(45)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(15)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-15)
            make.bottom.equalTo(genderHStack.snp.bottom).offset(100)
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
    
    private func createFilterLabel(text: String, font: UIFont) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        return label
    }
    
    private func createFilterStack(axis: NSLayoutConstraint.Axis, spacing: CGFloat, distribution: UIStackView.Distribution?) -> UIStackView {
        let stack = UIStackView()
        stack.axis = axis
        stack.spacing = spacing
        if let distribution = distribution {
            stack.distribution = distribution
        }
        return stack
    }
    
    private func createFilterButton(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
        return button
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
            HomeViewModel.viewIsUpdate = true
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
