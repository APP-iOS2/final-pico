//
//  HomeFilterViewController.swift
//  Pico
//
//  Created by 임대진 on 2023/09/26.
//

import UIKit
import SnapKit

final class HomeFilterViewController: UIViewController {
    private let genderButtonLabel = ["남자", "여자", "기타"]
    
    private let selectedGenderLabel: UILabel = {
        let label = UILabel()
        label.text = "만나고 싶은 성별"
        return label
    }()
    
    private let selectedGenderSubLabel: UILabel = {
        let label = UILabel()
        label.text = "중복 선택 가능"
        return label
    }()
    
    private let selectedAge: UILabel = {
        let label = UILabel()
        label.text = "나이"
        return label
    }()
    
    private let selectedDistance: UILabel = {
        let label = UILabel()
        label.text = "거리"
        return label
    }()
    
    private let selectedMBTI: UILabel = {
        let label = UILabel()
        label.text = "MBTI"
        return label
    }()
    
    private let manButton: UIButton = {
        let button = UIButton()
        button.setTitle("남자", for: .normal)
        return button
    }()
    
    private let womanButton: UIButton = {
        let button = UIButton()
        button.setTitle("여자", for: .normal)
        return button
    }()
    
    private let etcButton: UIButton = {
        let button = UIButton()
        button.setTitle("기타", for: .normal)
        return button
    }()
    
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
    
    private let genderHStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let genderLabelVStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()
    
    private let genderButtonHStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.backgroundColor = .gray.withAlphaComponent(0.5)
        stack.distribution = .fillEqually
        return stack
    }()
    private let vStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 5
        return stack
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        self.navigationItem.title = "선호 설정"
        addSubView()
        makeConstraints()
    }
    
    func addSubView() {
        view.addSubview(vStack)
        vStack.addArrangedSubview(genderHStack)
        
        genderHStack.addArrangedSubview(genderLabelVStack)
        genderHStack.addArrangedSubview(genderButtonHStack)
        
        genderLabelVStack.addArrangedSubview(selectedGenderSubLabel)
        genderLabelVStack.addArrangedSubview(selectedGenderLabel)
        
        genderButtonHStack.addArrangedSubview(manButton)
        genderButtonHStack.addArrangedSubview(womanButton)
        genderButtonHStack.addArrangedSubview(etcButton)
        
        vStack.addArrangedSubview(selectedAge)
        vStack.addArrangedSubview(ageSlider)
        vStack.addArrangedSubview(selectedDistance)
        vStack.addArrangedSubview(distanceSlider)
    }
    
    func makeConstraints() {
        
        vStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-10)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        genderHStack.snp.makeConstraints { make in
            make.top.equalTo(vStack.snp.top)
        }
    }
}
