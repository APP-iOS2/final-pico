//
//  ProfileEditCollectionTextModalViewController.swift
//  Pico
//
//  Created by 김민기 on 2023/10/13.
//

import UIKit
import SnapKit
import RxSwift
/*취미, 성격*/
final class ProfileEditCollTextModalViewController: UIViewController {
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
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .picoDescriptionFont
        label.textColor = .picoFontGray
        label.text = "0/7"
        return label
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.font = .picoTitleFont
        textField.textColor = .black
        return textField
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("등록", for: .normal)
        button.tintColor = .black
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        button.isEnabled = false
        button.backgroundColor = .picoGray
        button.layer.masksToBounds = false
        button.layer.cornerRadius = 13
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "x.circle"), for: .normal)
        button.tintColor = .picoGray
        button.imageView?.contentMode = .scaleAspectFit
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.isHidden = true
        return button
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
    
    private let collectionViewFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 18
        layout.minimumInteritemSpacing = 10
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewFlowLayout)
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.delegate = self
        view.dataSource = self
        view.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        view.register(ProfileEditTextModalCollectionCell.self, forCellWithReuseIdentifier: "ProfileEditTextModalCollectionCell")
        return view
    }()
    
    private let profileEditViewModel: ProfileEditViewModel
    private let disposeBag = DisposeBag()
    private var collectionData = [String]()
    
    init(profileEditViewModel: ProfileEditViewModel) {
        self.profileEditViewModel = profileEditViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addViews()
        makeConstraints()
        textFieldConfigure()
        binds()
    }
    
    private func binds() {
        
        backButton.rx.tap
            .bind { [weak self] _ in
                guard let self else { return }
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        completeButton.rx.tap
            .bind { [weak self] _ in
                guard let self else { return }
                self.profileEditViewModel.updateData(data: self.collectionData)
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .bind { [weak self] _ in
                guard let self else { return }
                self.self.textField.text = ""
            }
            .disposed(by: disposeBag)
        
        registerButton.rx.tap
            .bind { [weak self] _ in
                guard let self else { return }
                self.tappedRegister(text: self.textField.text)
            }
            .disposed(by: disposeBag)
        
        profileEditViewModel.modalName
            .bind(to: textField.rx.placeholder)
            .disposed(by: disposeBag)
        
        profileEditViewModel.modalName
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        collectionData = profileEditViewModel.collectionData ?? []
        countLabel.text = "\(collectionData.count)/7"
    }
    
    private func textFieldConfigure() {
        textField.delegate = self
    }
    
    private func addViews() {
        view.addSubview([backButton, titleLabel, collectionView, countLabel, textField, cancelButton, registerButton, completeButton])
    }
    
    private func makeConstraints() {
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-15)
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalTo(countLabel.snp.leading).offset(-15)
            make.height.equalTo(40)
        }
        
        countLabel.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.top)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(40)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.centerY.equalTo(textField.snp.centerY)
            make.leading.equalTo(textField.snp.trailing)
            make.trailing.equalTo(registerButton.snp.leading).offset(-8)
            make.width.equalTo(40)
        }
        
        registerButton.snp.makeConstraints { make in
            make.centerY.equalTo(textField.snp.centerY)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(35)
            make.width.equalTo(55)
        }
        
        completeButton.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
    }
    
    private func checkSameData() {
        let loadData = profileEditViewModel.collectionData ?? []
        if loadData == collectionData {
            completeButton.isEnabled = false
            completeButton.backgroundColor = .picoGray
        } else {
            completeButton.isEnabled = true
            completeButton.backgroundColor = .picoBlue
        }
    }
    
    private func checkNewData(text: String) {
        if collectionData.contains(text) {
            registerButton.isEnabled = false
            registerButton.backgroundColor = .picoGray
        } else {
            registerButton.isEnabled = true
            registerButton.backgroundColor = .picoBlue
        }
    }
    
    private func cheeckCollectionCount() -> Bool {
        if collectionData.count >= 7 {
            showCustomAlert(alertType: .onlyConfirm, titleText: "알림", messageText: "최대 7개까지만 선택할 수 있습니다.", confirmButtonText: "확인")
            return false
        } else {
            return true
        }
    }
    private func tappedRegister(text: String?) {
        textField.text = ""
        guard let text, !text.isEmpty else { return }
        let trimmedText = text.trimmed()
        guard !trimmedText.isEmpty else { return }
        guard cheeckCollectionCount() else { return }
        collectionData.append(trimmedText)
        countLabel.text = "\(collectionData.count)/7"
        collectionView.reloadData()
        checkSameData()
    }
    
    @objc private func tappedDeleteButton(_ sender: UIButton) {
        let index = sender.tag
        collectionData.remove(at: index)
        collectionView.reloadData()
        checkSameData()
    }
}

extension ProfileEditCollTextModalViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath, cellType: ProfileEditTextModalCollectionCell.self)
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(tappedDeleteButton), for: .touchUpInside)
        cell.configure(content: collectionData[indexPath.row])
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        let text = collectionData[indexPath.row]
        label.text = text
        label.sizeToFit()
        let size = label.frame.size
        return CGSize(width: size.width + 35, height: 30)
    }
}

extension ProfileEditCollTextModalViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        cancelButton.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        cancelButton.isHidden = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        checkNewData(text: updatedText)
        if let text = textField.text {
            if text.count > 10 {
                return false
            } else {
                return true
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !collectionData.contains(self.textField.text ?? "") {
            self.tappedRegister(text: self.textField.text)
            return true
        } else {
            return false
        }
    }
}
