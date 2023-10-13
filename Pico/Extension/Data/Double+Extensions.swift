//
//  Double+Extensions.swift
//  Pico
//
//  Created by 최하늘 on 10/6/23.
//

import Foundation

extension Double {
    enum DateSeparator {
        case dash
        case dot
    }
    
    /// Double -> yyyy-mm-dd 으로 변환
    func toString(dateSeparator: DateSeparator = .dash) -> String {
        let date = Date(timeIntervalSince1970: self)

        let dateFormatter = DateFormatter()
        switch dateSeparator {
        case .dash:
            dateFormatter.dateFormat = "yyyy-MM-dd"
        case .dot:
            dateFormatter.dateFormat = "yyyy.MM.dd"
        }

        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
    
    func toStringTime() -> String {
        let date = Date(timeIntervalSince1970: self)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
}
