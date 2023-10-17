//
//  Int+Extensions.swift
//  Pico
//
//  Created by 최하늘 on 10/17/23.
//

import Foundation

extension Int {
    func formattedSeparator() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}
