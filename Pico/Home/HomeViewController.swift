//
//  ViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import SnapKit

final class HomeViewController: UIViewController {
    
    let button: CommonButton = {
        let button = CommonButton()
        button.setTitle("다음", for: .normal)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
        
        view.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.top.equalTo(200)
            make.height.equalTo(Constraint.Button.commintHeight)
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
        }
        
        button.addTarget(self, action: #selector(tappeddd), for: .touchUpInside)
    }
    
    @objc func tappeddd(_ button: UIButton) {
        print("11")
    }
}
