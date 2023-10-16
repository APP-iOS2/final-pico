//
//  FooterView.swift
//  Pico
//
//  Created by 방유빈 on 2023/10/16.
//

import UIKit
import SnapKit

final class FooterView: UIView {
    let indicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .picoBlue
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        indicatorView.startAnimating()
    }
    
    private func makeConstraints() {
        addSubview(indicatorView)
        indicatorView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}
