//
//  BottomUserDetailViewController.swift
//  Pico
//
//  Created by 신희권 on 2023/09/26.
//

import UIKit
import SnapKit

class BottomUserDetailViewController: UIViewController {
    private let user = User.userData
    
    private let hobbyLabel: UILabel = {
        let label = UILabel()
        label.text = "내 취미"
        label.font = UIFont.picoSubTitleFont
        return label
    }()
    
    private let personalLabel: UILabel = {
        let label = UILabel()
        label.text = "내 성격"
        label.font = UIFont.picoSubTitleFont
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        makeConstraints()
    }
    
    final private func addViews() {
        view.addSubview(hobbyLabel)
        view.addSubview(personalLabel)
    }
    
    final private func makeConstraints() {
        hobbyLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(10)
        }
    }

}
