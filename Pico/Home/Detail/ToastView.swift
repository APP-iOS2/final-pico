//
//  ToastView.swift
//  Pico
//
//  Created by 신희권 on 10/23/23.
//

import UIKit

class ToastView: UIView {
    private let toastLabel: UILabel
    
    init(text: String, backgroundColor: UIColor, textColor: UIColor) {
        let frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        toastLabel = UILabel(frame: frame)
        toastLabel.text = text
        toastLabel.font = .boldSystemFont(ofSize: 16)
        toastLabel.textColor = textColor
        toastLabel.textAlignment = .center
        toastLabel.backgroundColor = backgroundColor.withAlphaComponent(0.8)
        toastLabel.layer.cornerRadius = 5
        toastLabel.clipsToBounds = true
        
        super.init(frame: frame)
        addSubview(toastLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Show the toast message
    func show(duration: TimeInterval = 2.0) {
        self.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 1
        }) { (completed) in
            if completed {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    self.hide()
                }
            }
        }
    }
    
    // Hide the toast message
    func hide() {
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0
        }) { (completed) in
            if completed {
                self.removeFromSuperview()
            }
        }
    }
}
