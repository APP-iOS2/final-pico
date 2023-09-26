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
        label.font = .boldSystemFont(ofSize: 25)
        return label
    }()
    
    private let selectedGenderSubLabel: UILabel = {
        let label = UILabel()
        label.text = "중복 선택 가능"
        label.font = .systemFont(ofSize: 10)
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
        button.backgroundColor = .picoBlue
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        return button
    }()
    
    private let womanButton: UIButton = {
        let button = UIButton()
        button.setTitle("여자", for: .normal)
        button.backgroundColor = .picoBlue
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        return button
    }()
    
    private let etcButton: UIButton = {
        let button = UIButton()
        button.setTitle("기타", for: .normal)
        button.backgroundColor = .picoBlue
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
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
    
    // MARK: - 스택
    private let vStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 5
        return stack
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
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let ageVStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()
    
    private let distanceVStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        self.navigationItem.title = "선호 설정"
        addSubView()
        makeConstraints()
    }
    
    func addSubView() {
//        view.addSubview(vStack)
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
        
//        vStack.snp.makeConstraints { make in
//            make.top.equalTo(view.safeAreaLayoutGuide).offset(30)
//            make.leading.equalTo(view.safeAreaLayoutGuide).offset(15)
//            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-15)
//            make.bottom.equalTo(view.safeAreaLayoutGuide)
//        }
        
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
}
