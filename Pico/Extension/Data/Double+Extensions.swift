//
//  Double+Extensions.swift
//  Pico
//
//  Created by 최하늘 on 10/6/23.
//

import Foundation

extension Double {
    /// Double -> yyyy.mm.dd 으로 변환
    func toString() -> String {
        let date = Date(timeIntervalSince1970: self)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"

        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
}
