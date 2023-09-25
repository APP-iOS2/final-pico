//
//  CommonButton.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit

final class CommonButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.titleLabel?.font = .picoButtonFont
        self.setTitleColor(.white, for: .normal)
        self.backgroundColor = .picoBlue
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tappedButton() {
        self.isSelected.toggle()
        self.backgroundColor = self.isSelected ? .picoAlphaBlue : .picoBlue
    }
}
