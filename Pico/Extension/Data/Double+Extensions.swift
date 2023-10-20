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
    
    func toStringTime(dateSeparator: DateSeparator = .dash) -> String {
        let date = Date(timeIntervalSince1970: self)

        let dateFormatter = DateFormatter()
        switch dateSeparator {
        case .dash:
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        case .dot:
            dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        }
        
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
    
    func timeAgoSinceDate() -> String {
        let date = Date(timeIntervalSince1970: self)
        let currentDate = Date()

        let seconds: Int = Int(currentDate.timeIntervalSince(date))
        if seconds < 60 {
            return "\(seconds)초 전"
        }
        
        let minutes = seconds / 60
        if minutes < 60 {
            return "\(minutes)분 전"
        }
        
        let hour = minutes / 60
        if hour < 24 {
            return "\(hour)시간 전"
        }
        
        let day = hour / 24
        if day < 30 {
            return "\(day)일 전"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월 dd일"
        let result = formatter.string(from: date)
        
        return result
    }

}
