//
//  PictureService.swift
//  Pico
//
//  Created by LJh on 10/16/23.
//
import UIKit
import Photos

final class PictureService {
    func unauthorized(in viewController: UIViewController) {
        DispatchQueue.main.async {
            viewController.showCustomAlert(alertType: .canCancel, titleText: "사진 라이브러리 권한 필요", messageText: "사진을 선택하려면 사진 라이브러리 권한이 필요합니다. 설정에서 권한을 변경할 수 있습니다.", confirmButtonText: "설정으로 이동", comfrimAction: {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            })
        }
    }

    func requestPhotoLibraryAccess(in viewController: UIViewController) {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            switch status {
            case .authorized:
                break
            case .denied, .restricted, .notDetermined, .limited:
                self.unauthorized(in: viewController)
            @unknown default:
                self.unauthorized(in: viewController)
            }
        }
    }
}
