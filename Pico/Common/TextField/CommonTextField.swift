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
        button.isHidden = true
        return button
    }()
    
    /// 최대 글자 수 제한
    private var maxLength: Int
    
    init(frame: CGRect = .zero, maxLength: Int = 0) {
        self.maxLength = maxLength
        super.init(frame: frame)
        
        addViews()
        makeConstraints()
        configTextField()
        configButtons()
        configBorder(color: .picoGray)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configTextField() {
        textField.delegate = self
    }
    
    private func configButtons() {
        removeAllButton.addTarget(self, action: #selector(tappedRemoveAllButton), for: .touchUpInside)
    }
    
    @objc private func tappedRemoveAllButton(_ sender: UIButton) {
        textField.text = ""
        removeAllButton.isHidden = true
    }
}

extension CommonTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        configBorder(color: .picoBlue)
        removeAllButton.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        configBorder(color: .picoGray)
        removeAllButton.isHidden = true
    }
    
    private func configBorder(color: UIColor) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard maxLength > 0 else { return true }
        
        let currentText = textField.text ?? ""
        var newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        newText = newText.replacingOccurrences(of: " ", with: "")
        
        return newText.count <= maxLength
    }
}

// MARK: - UI 관련
extension CommonTextField {
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
