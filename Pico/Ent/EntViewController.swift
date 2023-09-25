//
//  EntViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import SnapKit

final class EntViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    
    private let randomBoxButton: RandomBoxBanner = {
        let button = RandomBoxBanner()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addViews()
        setLayoutConstraints()
    }
    
    func addViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(randomBoxButton)
    }
    
    func setLayoutConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        randomBoxButton.snp.makeConstraints { make in
            make.edges.equalTo(0).inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            make.height.equalTo(100)
            make.width.equalToSuperview().offset(-40)
        }
    }
}
