//
//  EntViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import SnapKit

final class EntViewController: UIViewController {
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        setLayoutConstraints()
    }
    
    func addViews() {
        [scrollView].forEach { item in
            view.addSubview(item)
            item.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setLayoutConstraints() {

    }
}
