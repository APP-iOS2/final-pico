//
//  String+Extensions.swift
//  Pico
//
//  Created by 방유빈 on 2023/10/04.
//

import Foundation

extension String {
    /// String -> Date 바꾸기
    func toDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.date(from: self) ?? Date()
    }
    
    /// 전화번호 3자리 7자리에 "-" 넣기
    func formattedTextFieldText() -> String {
        var formattedText: String = ""
        
        for (index, character) in self.enumerated() {
            if index == 3 || index == 7 {
                formattedText += "-"
            }
            formattedText.append(character)
        }
        
        return formattedText
    }
    
    /// 좌우 공백자르기
    func trimmed() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
