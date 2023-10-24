//
//  KeyboardService.swift
//  Pico
//
//  Created by LJh on 10/16/23.
//

import Foundation
import UIKit

final class KeyboardService {
    var button: UIButton?
    
    func registerKeyboard(with button: UIButton) {
        self.button = button
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unregisterKeyboard() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        button = nil
    }
    
    @objc func keyboardUp(_ notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
           let button = button {
            let keyboardRectangle = keyboardFrame.cgRectValue
            
            UIView.animate(
                withDuration: 0.5,
                animations: {
                    button.transform = CGAffineTransform(translationX: 0, y: -keyboardRectangle.height + 25)
                }
            )
        }
    }
    
    @objc private func keyboardDown(_ notification: NSNotification) {
        if let button = button {
            button.transform = .identity
        }
    }
}
