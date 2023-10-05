//
//  StringToDate.swift
//  Pico
//
//  Created by 방유빈 on 2023/10/04.
//

import Foundation

extension String {
    func toDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.date(from: self) ?? Date()
    }
}
