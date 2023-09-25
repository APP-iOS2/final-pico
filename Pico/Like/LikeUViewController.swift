//
//  LikeUViewController.swift
//  Pico
//
//  Created by 방유빈 on 2023/09/25.
//

import UIKit

final class LikeUViewController: UIViewController {
    lazy var emptyView: UIView = LikeEmptyView(frame: view.frame, type: .iLikeU)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        makeConstraints()
    }
    
    private func addViews() {
        view.addSubview(emptyView)
    }
    
    private func makeConstraints() {
        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
