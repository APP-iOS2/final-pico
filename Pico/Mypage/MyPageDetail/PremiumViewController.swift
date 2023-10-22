//
//  PremiumViewController.swift
//  Pico
//
//  Created by 김민기 on 2023/10/19.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class PremiumViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "준비중"
        label.textColor = .picoFontBlack
        label.textAlignment = .center
        label.font = .picoProfileNameFont
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "조금만 기다려주세요......"
        label.textColor = .picoFontBlack
        label.textAlignment = .center
        label.font = .picoContentFont
        return label
    }()
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "chu")
        view.contentMode = .scaleAspectFit
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewConfig()
        addSubView()
        makeConstraints()
    }
  
    private func viewConfig() {
        title = "파워 매칭"
        view.configBackgroundColor()
    }
    
    private func addSubView() {
        view.addSubview([titleLabel, subTitleLabel, imageView])
    }
    
    private func makeConstraints() {
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-100)
            make.height.equalTo(180)
            make.width.equalTo(150)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
    }
}
