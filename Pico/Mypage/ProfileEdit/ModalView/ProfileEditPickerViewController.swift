//
//  ProfileEditPickerViewController.swift
//  Pico
//
//  Created by 김민기 on 2023/10/18.
//

import UIKit
import SnapKit
import RxSwift

final class ProfileEditPickerViewController: UIViewController {
    private let backButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        let image = UIImage(systemName: "xmark", withConfiguration: imageConfig)
        let button = UIButton()
        button.layer.masksToBounds = false
        button.layer.cornerRadius = 12
        button.backgroundColor = .picoGray
        button.setImage(image, for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .picoSubTitleFont
        label.textColor = .picoFontBlack
        return label
    }()
    
    private let completeButton: UIButton = {
        let button = UIButton()
        button.setTitle("완료", for: .normal)
        button.layer.masksToBounds = false
        button.layer.cornerRadius = 15
        button.backgroundColor = .picoGray
        button.isEnabled = false
        return button
    }()
    
    private let pickerView = UIPickerView()
    private let heightsInCm: [Int] = Array(140...220)
    private let profileEditViewModel: ProfileEditViewModel?
    private let disposeBag = DisposeBag()
    private var selectedHeight = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.configBackgroundColor()
        addViews()
        makeConstraints()
        pickerConfig()
        binds()
    }
    
    init(profileEditViewModel: ProfileEditViewModel) {
        self.profileEditViewModel = profileEditViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func pickerConfig() {
        pickerView.delegate = self
        pickerView.dataSource = self
        if let height =
            profileEditViewModel?.userData?.subInfo?.height {
            pickerView.selectRow(height - heightsInCm[0], inComponent: 0, animated: false)
        }
    }
    
    private func binds() {
        profileEditViewModel?.modalName
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .bind { [weak self] _ in
                guard let self else { return }
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        completeButton.rx.tap
            .bind { [weak self] _ in
                guard let self else { return }
                self.profileEditViewModel?.updateData(data: selectedHeight)
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func addViews() {
        view.addSubview([backButton, titleLabel, pickerView, completeButton])
    }
    
    private func makeConstraints() {
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-15)
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        
        pickerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(100)
        }
        
        completeButton.snp.makeConstraints { make in
            make.top.equalTo(pickerView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
    }
}

extension ProfileEditPickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return heightsInCm.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(heightsInCm[row]) cm"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let selectedHeightInCm = heightsInCm[row]
        if let height = profileEditViewModel?.userData?.subInfo?.height {
            if height == selectedHeightInCm {
                completeButton.isEnabled = false
                completeButton.backgroundColor = .picoGray
            } else {
                completeButton.isEnabled = true
                completeButton.backgroundColor = .picoBlue
            }
        } else {
            completeButton.isEnabled = true
            completeButton.backgroundColor = .picoBlue
        }
        selectedHeight = selectedHeightInCm
    }
}
