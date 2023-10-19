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
    private var currentYear: Int = {
        let currentYear = Calendar.current.component(.year, from: Date())
        return currentYear - 100
    }()

    private let years: [Int] = {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array(currentYear - 100...2023 - 19)
    }()

    private let months = Array(1...12)
    private var days: [Int] = []
    let viewModel: SignUpViewModel
    
    init(viewModel: SignUpViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private var userAge: String {
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
        let dateString = "\(selectedYear)-\(String(format: "%02d", selectedMonth))-\(String(format: "%02d", selectedDay))"
         
        return dateString
    }
    
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = .lightGray
        view.progressTintColor = .picoBlue
        view.layer.cornerRadius = SignView.progressViewCornerRadius
        view.layer.masksToBounds = true
        view.progress = viewModel.progressStatus
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
        view.configBackgroundColor()
        configNavigationBackButton()
        addSubViews()
        makeConstraints()
        configDatePicker()
    }
    override func viewDidAppear(_ animated: Bool) {
        viewModel.animateProgressBar(progressView: progressView, endPoint: 4)
    }
}
// MARK: - Config
extension SignUpAgeViewController {
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
    
    // MARK: - @objc
    @objc private func tappedNextButton(_ sender: UIButton) {
        if isChoiceAge {
            viewModel.birth = userAge
            sender.tappedAnimation()
            let viewController = SignUpNickNameViewController(viewModel: viewModel)
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
            make.top.equalTo(safeArea).offset(SignView.progressViewTopPadding)
            make.leading.equalTo(SignView.padding)
            make.trailing.equalTo(-SignView.padding)
            make.height.equalTo(8)
        }
        
        notifyLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(SignView.padding)
            make.leading.equalTo(SignView.padding)
            make.trailing.equalTo(-SignView.padding)
        }
        
        subNotifyLabel.snp.makeConstraints { make in
            make.top.equalTo(notifyLabel.snp.bottom).offset(SignView.subPadding)
            make.leading.equalTo(notifyLabel.snp.leading)
            make.trailing.equalTo(notifyLabel.snp.trailing)
        }
        
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(subNotifyLabel.snp.bottom).offset(SignView.contentPadding)
            make.leading.equalTo(SignView.contentPadding)
            make.trailing.equalTo(-SignView.contentPadding)
            make.height.equalTo(150)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.equalTo(notifyLabel.snp.leading)
            make.trailing.equalTo(notifyLabel.snp.trailing)
            make.bottom.equalTo(safeArea).offset(SignView.bottomPadding)
            make.height.equalTo(CommonConstraints.buttonHeight)
        }
    }
}
