//
//  BaseViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/26.
//

import UIKit
import SnapKit

class BaseViewController: UIViewController {
    
    private let labelView: MBTILabelView = MBTILabelView(mbti: .entp)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(labelView)
        
        labelView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.equalTo(labelView.frame.size.height)
            make.width.equalTo(labelView.frame.size.width)
        }
    }
}
