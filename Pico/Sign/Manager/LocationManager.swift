//
//  LocationManager.swift
//  Pico
//
//  Created by LJh on 10/6/23.
//

import UIKit
import SnapKit
import CoreLocation
import RxSwift
import RxRelay

final class LocationManager: CLLocationManager, CLLocationManagerDelegate {
    
    var viewModel: SignUpViewModel = .shared
    static var shared = LocationManager()
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var longitude: Double?
    var latitude: Double?
    
    func configLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager.startUpdatingLocation()
            } else {
                print("위치 서비스에 동의를 안하셨네요?")
            }
        }
    }
    
    func getAddress(latitude: CLLocationDegrees?, longitude: CLLocationDegrees?, completion: @escaping (Location?) -> Void) {
        let location = CLLocation(latitude: latitude ?? 0, longitude: longitude ?? 0)
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Geocoding Error: \(error)")
                completion(nil)
                return
            }

            if let placemark = placemarks?.first {
                let addressString = "\(placemark.thoroughfare ?? "") \(placemark.subThoroughfare ?? ""), \(placemark.locality ?? "") \(placemark.postalCode ?? ""), \(placemark.country ?? "")"
                let location = Location(address: addressString, latitude: latitude ?? 0, longitude: longitude ?? 0)
                completion(location)
            } else {
                completion(nil)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
