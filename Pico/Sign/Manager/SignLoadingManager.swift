//
//  SignLoadingManager.swift
//  Pico
//
//  Created by LJh on 10/15/23.
//
import UIKit
import SnapKit

final class SignLoadingManager {
    
    static func showLoading(text: String) {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.last {
                let loadingView: SignLoadingAnimationView
                if let existedView = window.subviews.first(where: {
                    $0 is SignLoadingAnimationView
                }) as? SignLoadingAnimationView {
                    loadingView = existedView
                } else {
                    loadingView = SignLoadingAnimationView(waitText: text)
                    loadingView.frame = window.frame
                    window.addSubview(loadingView)
                }
                loadingView.animate()
            }
        }
    }

    static func hideLoading() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.last {
                window.subviews.filter({ $0 is SignLoadingAnimationView }).forEach { $0.removeFromSuperview() }
            }
        }
    }
}
