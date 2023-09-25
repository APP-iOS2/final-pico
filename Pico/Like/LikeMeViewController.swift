//
//  LikeMeViewController.swift
//  Pico
//
//  Created by 방유빈 on 2023/09/25.
//

import UIKit

final class LikeMeViewController: UIViewController {
    let emptyView: UIView = LikeEmptyView(frame: CGRect(x: 0, y: 0, width: Screen.height, height: Screen.width), type: .uLikeMe)
    
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
