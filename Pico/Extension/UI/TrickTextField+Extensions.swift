//
//  TrickTextField+Extensions.swift
//  Pico
//
//  Created by 오영석 on 12/15/23.
//

import Foundation
import UIKit

private var AssociatedObjectHandle = 0

extension UIView {
    private var secureTextField: UITextField {
        if let textField = objc_getAssociatedObject(self, &AssociatedObjectHandle) as? UITextField {
            return textField
        } else {
            let textField = UITextField()
            addSubview(textField)
            textField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            textField.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            textField.layer.removeFromSuperlayer()
            layer.superlayer?.insertSublayer(textField.layer, at: 0)
            textField.layer.sublayers?.last?.addSublayer(layer)
            objc_setAssociatedObject(self, &AssociatedObjectHandle, textField, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return textField
        }
    }
    
    func secureMode(enable: Bool) {
        secureTextField.isSecureTextEntry = enable
    }
}
