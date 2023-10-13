//
//  AdminUserDetailViewController.swift
//  Pico
//
//  Created by 최하늘 on 10/12/23.
//

import UIKit
import SnapKit

final class AdminUserDetailViewController: UIViewController {
    // 뷰컨트롤러로 변경해서 수정했습니다.
    private let userImageViewContoller: UIViewController = UserImageViewControll()
    
    private var user: User!
    
    init(user: User) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.configBackgroundColor()
        addViews()
        makeConstraints()
    }
}

extension AdminUserDetailViewController {
    private func addViews() {
        view.addSubview(userImageViewContoller.view)
    }
    
    private func makeConstraints() {
        userImageViewContoller.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
