//
//  BaseViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/26.
//

import UIKit
import SnapKit

class BaseViewController: UIViewController {
    
    private let labelView: CommonTextField = CommonTextField(maxLength: 10)
    private let labelView1: MBTILabelView = MBTILabelView()
    private let labelView2: MBTILabelView = MBTILabelView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(labelView)
        view.addSubview(labelView1)
        view.addSubview(labelView2)

        labelView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(200)
            make.leading.trailing.equalToSuperview().inset(100)
            make.height.equalTo(40)
        }
        
        labelView1.snp.makeConstraints { make in
            make.top.equalTo(labelView.snp.bottom).offset(40)
            make.leading.equalTo(10)
            make.height.equalTo(labelView1.frame.size.height)
            make.width.equalTo(labelView1.frame.size.width)
        }
        
        labelView2.snp.makeConstraints { make in
            make.top.equalTo(labelView1.snp.top)
            make.trailing.equalToSuperview().offset(40)
            make.height.equalTo(labelView2.frame.size.height)
            make.width.equalTo(labelView2.frame.size.width)
        }
    }
}
