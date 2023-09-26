//
//  CommonTextField.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/26.
//

import UIKit
import SnapKit

/*
 사용법
 1. 글자수 제한 없을 경우 : private let commonTextField: CommonTextField = CommonTextField()
 2. 글자수 제한 있을 경우 : private let commonTextField: CommonTextField = CommonTextField(maxLength: 10)

 view.addSubview(commonTextField)
 
 commonTextField.snp.makeConstraints { make in
    // top, leading, trailing 제약조건 추가
    // height 40으로 고정해주세요
     make.height.equalTo(40)
 }
 */

final class CommonTextField: UIView {
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "입력해주세여"
        return textField
    }()
    
    private let removeAllButton: UIButton = {
        let button = UIButton(type: .custom)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        let image = UIImage(systemName: "x.circle", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .picoBlue
        return button
    }()
    
    // MARK: - 프로퍼티
    /// 최대 글자 수 제한
    private var maxLength: Int
    
    convenience init(frame: CGRect = .zero, maxLength: Int) {
        self.init(frame: frame)
        self.maxLength = maxLength
    }
    
    override init(frame: CGRect) {
        self.maxLength = 0
        super.init(frame: frame)
        configUI()
        addViews()
        makeConstraints()
        configTextField()
        configButtons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        self.layer.borderColor = UIColor.picoBlue.cgColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }
    
    private func configTextField() {
        textField.delegate = self
    }
    
    private func configButtons() {
        removeAllButton.addTarget(self, action: #selector(tappedRemoveAllButton), for: .touchUpInside)
    }
    
    @objc private func tappedRemoveAllButton(_ sender: UIButton) {
        textField.text = ""
    }
    
    private func addViews() {
        self.addSubview(textField)
        self.addSubview(removeAllButton)
    }
    
    private func makeConstraints() {
        let padding: CGFloat = 10
        
        textField.snp.makeConstraints { make in
            make.leading.equalTo(padding)
            make.centerY.equalToSuperview()
        }
        
        removeAllButton.snp.makeConstraints { make in
            make.leading.equalTo(textField.snp.trailing)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(textField.snp.centerY)
            make.width.equalTo(40)
        }
    }
}

extension CommonTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard maxLength > 0 else { return true }
        
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        return newText.count <= maxLength
    }
}
