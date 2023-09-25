//
//  LikeMeViewController.swift
//  Pico
//
//  Created by 방유빈 on 2023/09/25.
//

import UIKit

final class LikeMeViewController: UIViewController {
    let emptyView: LikeEmptyView = LikeEmptyView(frame: CGRect(x: 0, y: 0, width: Screen.height, height: Screen.width), type: .uLikeMe)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        makeConstraints()
        configButtons()
    }
    
    private func configButtons() {
        emptyView.linkButton.addTarget(self, action: #selector(tappedLinkButton), for: .touchUpInside)
    }
    
    private func addViews() {
        view.addSubview(emptyView)
    }
    
    private func makeConstraints() {
        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc func tappedLinkButton(_ sender: UIButton) {
        if let tabBarController = self.tabBarController as? TabBarController {
            tabBarController.selectedIndex = 0
        }
    }
}
