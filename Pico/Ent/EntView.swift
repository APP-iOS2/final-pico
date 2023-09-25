//
//  EntView.swift
//  Pico
//
//  Created by 오영석 on 2023/09/25.
//

import UIKit

final class EntView: UIView {
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        
        return scrollView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        addViews()
        setLayoutConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addViews(){
        [scrollView].forEach { item in
            addSubview(item)
            item.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setLayoutConstraints() {

    }
}

