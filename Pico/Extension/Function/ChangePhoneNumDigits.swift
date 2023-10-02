//
//  ChangePhoneNumDigits.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/29.
//

import UIKit

extension UIViewController {
    /// 전화번호 11자리 숫자 "-" 추가
    func changePhoneNumDigits(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String, isFull: (Bool) -> ()) -> Bool {
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        let digits = CharacterSet.decimalDigits
        let filteredText = updatedText.components(separatedBy: digits.inverted).joined()
        
        if filteredText.count > 11 {
            return false
        }
        
        if filteredText.count <= 3 || (filteredText.count > 3 && filteredText.count <= 10) {
            textField.text = formattedTextFieldText(filteredText)
            isFull(false)
            return false
        }
        
        if filteredText.count == 11 {
            textField.text = formattedTextFieldText(filteredText)
            isFull(true)
            return false
        }
        
        return true
    }
    
    private func formattedTextFieldText(_ filteredText: String) -> String {
        var formattedText: String = ""
        
        for (index, character) in filteredText.enumerated() {
            if index == 3 || index == 7 {
                formattedText += "-"
            }
            formattedText.append(character)
        }
        
        return formattedText
    }
}
