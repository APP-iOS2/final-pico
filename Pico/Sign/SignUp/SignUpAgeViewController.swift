//
//  SignUpAgeViewController.swift
//  Pico
//
//  Created by LJh on 2023/09/27.
//

import UIKit
import SnapKit

final class SignUpAgeViewController: UIViewController {
    
    private var isChoiceAge: Bool = false
    private var selectedYear: Int = 2000
    private var selectedMonth: Int = 1
    private var selectedDay: Int = 1
    
    private let years = Array(1900...2023)
    private let months = Array(1...12)
    private var days: [Int] = []
    
    private let progressView: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = .picoBetaBlue
        view.progressTintColor = .picoBlue
        view.progress = 0.142 * 4
        view.layer.cornerRadius = 5
        return view
    }()
    
    private let notifyLabel: UILabel = {
        let label = UILabel()
        label.text = "생년월일을 선택하세요"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.picoTitleFont
        return label
    }()
    
    private let subNotifyLabel: UILabel = {
        let label = UILabel()
        label.text = "생년월일은 변경이 불가능합니다‼️"
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.textColor = .picoFontGray
        label.font = UIFont.picoDescriptionFont
        return label
    }()
    
    private let datePicker: UIPickerView = {
        let picker = UIPickerView()
        return picker
    }()

    private lazy var nextButton: UIButton = {
        let button = CommonButton(type: .custom)
        button.setTitle("다음", for: .normal)
        button.backgroundColor = .picoGray
        button.addTarget(self, action: #selector(tappedNextButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addSubViews()
        makeConstraints()
        configDatePicker()
        configBackButton()
    }
}

extension SignUpAgeViewController {
    
    // MARK: - Config
    private func configNextButton() {
        isChoiceAge = true
        nextButton.backgroundColor = .picoBlue
    }
    private func configDatePicker() {
        datePicker.delegate = self
        datePicker.dataSource = self
        updateDaysForSelectedMonth()
        
        let initialYearIndex = years.firstIndex(of: selectedYear) ?? 0
        let initialMonthIndex = months.firstIndex(of: selectedMonth) ?? 0
        let initialDayIndex = days.firstIndex(of: selectedDay) ?? 0
        
        datePicker.selectRow(initialYearIndex, inComponent: 0, animated: false)
        datePicker.selectRow(initialMonthIndex, inComponent: 1, animated: false)
        datePicker.selectRow(initialDayIndex, inComponent: 2, animated: false)
    }
    // MARK: - Tapped
    @objc private func tappedNextButton(_ sender: UIButton) {
        
        if isChoiceAge {
            tappedButtonAnimation(sender)
            let viewController = SignUpNickNameViewController()
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
}

// MARK: - 피커 관련
extension SignUpAgeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    private func updateDaysForSelectedMonth() {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: selectedYear, month: selectedMonth)
        if let date = calendar.date(from: dateComponents) {
            let range = calendar.range(of: .day, in: .month, for: date)
            days = Array(1..<(range?.count ?? 1) + 1)
        } else {
            days = []
        }
        datePicker.reloadComponent(2)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return years.count
        case 1:
            return months.count
        case 2:
            return days.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(years[row])년"
        case 1:
            return "\(months[row])월"
        case 2:
            return "\(days[row])일"
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        configNextButton()
        switch component {
        case 0:
            selectedYear = years[row]
        case 1:
            selectedMonth = months[row]
            updateDaysForSelectedMonth()
        case 2:
            selectedDay = days[row]
        default:
            break
        }
    }
}
// MARK: - UI 관련
extension SignUpAgeViewController {

    private func addSubViews() {
        for viewItem in [progressView, notifyLabel, subNotifyLabel, datePicker, nextButton] {
            view.addSubview(viewItem)
        }
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(10)
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
            make.height.equalTo(8)
        }
        
        notifyLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(10)
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
            make.height.equalTo(50)
        }
        
        subNotifyLabel.snp.makeConstraints { make in
            make.top.equalTo(notifyLabel.snp.bottom).offset(-15)
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
            make.height.equalTo(50)
        }
        
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(subNotifyLabel.snp.bottom).offset(20)
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
            make.height.equalTo(150)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.bottom.equalTo(safeArea).offset(-30)
            make.height.equalTo(50)
        }
    }
}
