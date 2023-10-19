//
//  ViewModelType.swift
//  Pico
//
//  Created by 최하늘 on 10/11/23.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
