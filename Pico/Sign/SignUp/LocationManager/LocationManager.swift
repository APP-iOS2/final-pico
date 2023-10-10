//
//  LocationManager.swift
//  Pico
//
//  Created by LJh on 10/6/23.
//

import Foundation

final class LocationManager {
    static var shared = LocationManager()
    var longitude: Double?
    var latitude: Double?
}
