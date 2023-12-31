//
//  CircularProgressBarView.swift
//  Pico
//
//  Created by 김민기 on 2023/10/04.
//

import UIKit
import SnapKit
import RxSwift

final class CircularProgressBarView: UIView {
    
    private var circleLayer = CAShapeLayer()
    private var progressLayer = CAShapeLayer()
    private let startPoint = CGFloat(Double.pi * 0.7)
   
    private let circleLayerEndPoint = CGFloat(Double.pi * 2.3)
    private var endPointValue: Double = 0
    let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        createCircularPath()
    }
    
    func triggerLayoutSubviews() {
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func binds(_ viewModel: CircularProgressBarViewModel) {
        viewModel.profilePerfection
            .subscribe {
                self.endPointValue = $0
            }
            .disposed(by: disposeBag)
    }
    
    private func createCircularPath() {
        let endPoint = CGFloat((Double.pi * 0.7) + (Double.pi * 1.6) * endPointValue)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let circularPath = UIBezierPath(arcCenter: center, radius: 80, startAngle: startPoint, endAngle: circleLayerEndPoint, clockwise: true)
        let progressPath = UIBezierPath(arcCenter: center, radius: 80, startAngle: startPoint, endAngle: endPoint, clockwise: true)
        circleLayer.path = circularPath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineCap = .round
        circleLayer.lineWidth = 7.0
        circleLayer.strokeEnd = 1.0
        circleLayer.strokeColor = UIColor.lightGray.cgColor
        layer.addSublayer(circleLayer)
        
        progressLayer.path = progressPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.lineWidth = 7.0
        progressLayer.strokeEnd = 0
        progressLayer.strokeColor = UIColor.picoBlue.cgColor
        layer.addSublayer(progressLayer)
    }
    
    func progressAnimation(duration: TimeInterval) {
        let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        circularProgressAnimation.duration = duration
        circularProgressAnimation.toValue = 1.0
        circularProgressAnimation.fillMode = .forwards
        circularProgressAnimation.isRemovedOnCompletion = false
        progressLayer.add(circularProgressAnimation, forKey: "progressAnim")
    }
}
