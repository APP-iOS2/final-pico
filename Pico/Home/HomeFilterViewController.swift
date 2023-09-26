//
//  HomeFilterViewController.swift
//  Pico
//
//  Created by 임대진 on 2023/09/26.
//

import UIKit
import SnapKit

final class HomeFilterViewController: UIViewController {
    
    private lazy var selectedGenderLabel: UILabel = createFilterLabel(text: "만나고 싶은 성별", font: .picoTitleFont)
    private lazy var selectedGenderSubLabel: UILabel = createFilterLabel(text: "중복 선택 가능", font: .picoDescriptionFont)
    private lazy var selectedAge: UILabel = createFilterLabel(text: "나이", font: .picoSubTitleFont)
    private lazy var selectedDistance: UILabel = createFilterLabel(text: "거리", font: .picoSubTitleFont)
    private lazy var selectedMBTI: UILabel = createFilterLabel(text: "MBTI", font: .picoSubTitleFont)
    
    private lazy var manButton: UIButton = createFilterButton(title: "남자")
    private lazy var womanButton: UIButton = createFilterButton(title: "여자")
    private lazy var etcButton: UIButton = createFilterButton(title: "기타")
    
    private let ageSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 20
        slider.maximumValue = 40
        return slider
    }()
    
    private let distanceSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 100
        return slider
    }()
    
    // MARK: - 스택
    private lazy var genderHStack: UIStackView = createFilterStack(axis: .horizontal, spacing: 5, distribution: .fillEqually)
    private lazy var genderLabelVStack: UIStackView = createFilterStack(axis: .vertical, spacing: 0, distribution: nil)
    private lazy var genderButtonHStack: UIStackView = createFilterStack(axis: .horizontal, spacing: 5, distribution: .fillEqually)
    private lazy var ageVStack: UIStackView = createFilterStack(axis: .vertical, spacing: 0, distribution: nil)
    private lazy var distanceVStack: UIStackView = createFilterStack(axis: .vertical, spacing: 0, distribution: nil)
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        view.backgroundColor = .white
        self.navigationItem.title = "선호 설정"
        addSubView()
        makeConstraints()
    }
    
    func addSubView() {
        view.addSubview(genderHStack)
        view.addSubview(ageVStack)
        view.addSubview(distanceVStack)
        
        genderHStack.addArrangedSubview(genderLabelVStack)
        genderHStack.addArrangedSubview(genderButtonHStack)
        
        genderLabelVStack.addArrangedSubview(selectedGenderLabel)
        genderLabelVStack.addArrangedSubview(selectedGenderSubLabel)
        
        genderButtonHStack.addArrangedSubview(manButton)
        genderButtonHStack.addArrangedSubview(womanButton)
        genderButtonHStack.addArrangedSubview(etcButton)
        
        ageVStack.addArrangedSubview(selectedAge)
        ageVStack.addArrangedSubview(ageSlider)
        
        distanceVStack.addArrangedSubview(selectedDistance)
        distanceVStack.addArrangedSubview(distanceSlider)
    }
    
    func makeConstraints() {
        
        genderHStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(15)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-15)
            make.height.equalTo(40)
        }
        
        ageVStack.snp.makeConstraints { make in
            make.top.equalTo(genderHStack.snp.bottom).offset(5)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(15)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-15)
            make.bottom.equalTo(genderHStack.snp.bottom).offset(100)
        }
        
        distanceVStack.snp.makeConstraints { make in
            make.top.equalTo(ageVStack.snp.bottom).offset(5)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(15)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-15)
            make.bottom.equalTo(ageVStack.snp.bottom).offset(100)
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
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .picoBlue
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.picoBlue.cgColor
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
        return button
    }
    
    @objc func tappedButton(_ sender: UIButton) {
        if sender.backgroundColor == .white {
            sender.backgroundColor = .picoBlue
            sender.setTitleColor(.white, for: .normal)
        } else {
            sender.backgroundColor = .white
            sender.setTitleColor(.picoFontGray, for: .normal)
        }
        
    }
}
