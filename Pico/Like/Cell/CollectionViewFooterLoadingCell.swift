//
//  CollectionViewFooterLoadingCell.swift
//  Pico
//
//  Created by 방유빈 on 2023/10/16.
//

import UIKit

final class CollectionViewFooterLoadingCell: UICollectionReusableView {
    private let indicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .picoBlue
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeConstraints()
    }
    
    private func makeConstraints() {
        addSubview(indicatorView)
        indicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func startLoading() {
        indicatorView.startAnimating()
    }
    
    func stopLoading() {
        indicatorView.stopAnimating()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
