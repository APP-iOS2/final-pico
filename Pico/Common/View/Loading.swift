//
//  Loading.swift
//  Pico
//
//  Created by 방유빈 on 2023/10/04.
//

import UIKit

final class Loading {
    static func showLoading() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.last {
                let loadingView: LoadingAnimationView
                if let existedView = window.subviews.first(where: {
                    $0 is LoadingAnimationView
                }) as? LoadingAnimationView {
                    loadingView = existedView
                } else {
                    loadingView = LoadingAnimationView()
                    loadingView.frame = window.frame
                    window.addSubview(loadingView)
                }
                loadingView.animate()
            }
        }
    }
    
    static func showWhiteLoading() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.last {
                let loadingView: LoadingAnimationView
                if let existedView = window.subviews.first(where: {
                    $0 is LoadingAnimationView
                }) as? LoadingAnimationView {
                    loadingView = existedView
                } else {
                    loadingView = LoadingAnimationView()
                    loadingView.frame = window.frame
                    loadingView.backgroundColor = .systemBackground
                    window.addSubview(loadingView)
                }
                loadingView.animateNow()
            }
        }
    }
    
    static func hideLoading() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.last {
                window.subviews.filter({ $0 is LoadingAnimationView }).forEach { $0.removeFromSuperview() }
            }
        }
    }
}
