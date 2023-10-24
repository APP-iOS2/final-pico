//
//  LocationService.swift
//  Pico
//
//  Created by LJh on 10/6/23.
//
import UIKit
import SnapKit
import CoreLocation
import RxSwift
import RxRelay

final class LocationService: CLLocationManager, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var longitude: Double?
    var latitude: Double?
    
    func accessLocation() {
        DispatchQueue.main.async {
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let viewController = windowScene.windows.first?.rootViewController {
                viewController.showCustomAlert(alertType: .canCancel, titleText: "위치 권한 필요", messageText: "이 앱을 사용하려면 위치 권한이 필요합니다. 설정에서 권한을 변경할 수 있습니다.", confirmButtonText: "설정으로 이동", comfrimAction: {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                })
            }
        }
    }
    
    func configLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            accessLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }

    func getAddress(latitude: CLLocationDegrees?, longitude: CLLocationDegrees?, completion: @escaping (Location?) -> Void) {
        let status = CLLocationManager()

        switch status.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
        let location = CLLocation(latitude: latitude ?? 0, longitude: longitude ?? 0)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "Ko-kr")) { (placemarks, error) in
            if let error = error {
                print("Geocoding Error: \(error)")
                completion(nil)
                return
            }
            if let placemark = placemarks?.first {
                var addressComponents = [String]()
                
                if let administrativeArea = placemark.administrativeArea {
                    addressComponents.append(administrativeArea)
                }

                if let subLocality = placemark.subLocality {
                    addressComponents.append(subLocality)
                }
                
                let addressString = addressComponents.joined(separator: " ")
                let location = Location(address: addressString, latitude: latitude ?? 0, longitude: longitude ?? 0)
                completion(location)
            } else {
                completion(nil)
            }
        }
        case .denied:
            completion(nil)
        default:
            completion(nil)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
