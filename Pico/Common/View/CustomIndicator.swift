//
//  CustomIndicator.swift
//  Pico
//
//  Created by 방유빈 on 2023/10/13.
//

import Foundation
import Kingfisher

/*
 사용법
 킹피셔로 이미지 설정할때 인디케이터 타입 앞에 설정해주기
 //cycleSize 기본값 large
 userImageView.kf.indicatorType = .custom(indicator: CustomIndicator(cycleSize: .small))
 userImageView.kf.setImage(with: url)
 */
/// 킹피셔 커스텀 인디케이터
final class CustomIndicator: Indicator {
    func startAnimatingView() {
        animationView.animate()
        view.isHidden = false
    }
    
    func stopAnimatingView() {
        view.isHidden = true
    }
    
    var cycleSize: LoadingAnimationView.CircleSize?
    var animationView: LoadingAnimationView
    var view: Kingfisher.IndicatorView {
        return animationView
    }
    
    init(cycleSize: LoadingAnimationView.CircleSize? = nil) {
        animationView = LoadingAnimationView(circleSize: cycleSize ?? .large)
    }
}
