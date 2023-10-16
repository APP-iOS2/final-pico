//
//  PictureManager.swift
//  Pico
//
//  Created by LJh on 10/16/23.
//
import UIKit
import PhotosUI
import Photos

final class PictureManager: UIViewController {
    func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                break
            case .denied, .restricted:
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "사진 라이브러리 권한 필요",
                                                            message: "사진을 선택하려면 사진 라이브러리 권한이 필요합니다. 설정에서 권한을 변경할 수 있습니다.",
                                                            preferredStyle: .alert)
                    
                    let settingsAction = UIAlertAction(title: "설정으로 이동", style: .default) { _ in
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                    }
                    
                    let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                    
                    alertController.addAction(settingsAction)
                    alertController.addAction(cancelAction)
                    
                    self.present(alertController, animated: true)
                }
            case .notDetermined:
                break
            case .limited:
                break
            @unknown default:
            break
            }
        }
    }
}
