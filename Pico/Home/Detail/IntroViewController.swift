//
//  IntroViewController.swift
//  Pico
//
//  Created by 신희권 on 10/23/23.
//

import UIKit

class IntroViewController: UIViewController {
    private let introLabel: UILabel = {
        let label = PaddingLabel(padding: UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 5))
        label.text = ""
        label.font = .picoSubTitleFont
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = .systemGray6
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        makeConstraints()
    }
    
    func config(intro: String?) {
        if let intro = intro {
            introLabel.text = intro
        } else {
            view.isHidden = true
        }
    }
}
// MARK: - UI어쩌구~
extension IntroViewController {
    private func addViews() {
        view.addSubview(introLabel)
    }
    
    private func makeConstraints() {
        introLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
