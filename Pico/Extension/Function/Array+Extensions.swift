//
//  Array+Extensions.swift
//  Pico
//
//  Created by 최하늘 on 10/9/23.
//

import Foundation

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
