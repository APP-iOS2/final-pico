//
//  ViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import SnapKit

final class HomeViewController: BaseViewController {
    
    private let emptyView: HomeEmptyView = HomeEmptyView()
    private var tempUser: [User] = []
    private let vStack: UIStackView = {
        let vStack = UIStackView()
        vStack.axis = .vertical
        return vStack
    }()
    
    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        tempUser = [
            User(mbti: .infp, phoneNumber: "01046275953", gender: .male, birth: "25", nickName: "닝닝", location: Location(address: "", latitude: 10, longitude: 10), imageURLs: [], createdDate: 10, subInfo: nil, reports: nil, blocks: nil, chuCount: 0, isSubscribe: false),
            User(mbti: .infp, phoneNumber: "01046275953", gender: .male, birth: "24", nickName: "지젤", location: Location(address: "", latitude: 10, longitude: 10), imageURLs: [], createdDate: 10, subInfo: nil, reports: nil, blocks: nil, chuCount: 0, isSubscribe: false),
            User(mbti: .infp, phoneNumber: "01046275953", gender: .male, birth: "23", nickName: "카리나", location: Location(address: "", latitude: 10, longitude: 10), imageURLs: [], createdDate: 10, subInfo: nil, reports: nil, blocks: nil, chuCount: 0, isSubscribe: false),
            User(mbti: .infp, phoneNumber: "01046275953", gender: .male, birth: "22", nickName: "윈터", location: Location(address: "", latitude: 10, longitude: 10), imageURLs: [], createdDate: 10, subInfo: nil, reports: nil, blocks: nil, chuCount: 0, isSubscribe: false)
        ]
        addSubView()
        makeConstraints()
        configNavigationBarItem()
        configButtons()
    }
    
    private func addSubView() {
        view.addSubview(emptyView)
        for user in self.tempUser {
            let tabImageViewController = HomeTabImageViewController(name: user.nickName, age: user.birth)
            addChild(tabImageViewController)
            view.addSubview(tabImageViewController.view)
        }
    }
    
    private func makeConstraints() {
        emptyView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func configButtons() {
        emptyView.reLoadButton.addTarget(self, action: #selector(reLoadView), for: .touchUpInside)
    }
    
    private func configNavigationBarItem() {
        let filterImage = UIImage(systemName: "slider.horizontal.3")
        let filterButton = UIBarButtonItem(image: filterImage, style: .plain, target: self, action: #selector(tappedFilterButton))
        filterButton.tintColor = .darkGray
        
        let notificationImage = UIImage(systemName: "bell.fill")
        let notificationButton = UIBarButtonItem(image: notificationImage, style: .plain, target: self, action: #selector(tappedNotificationButton))
        notificationButton.tintColor = .darkGray
        
        navigationItem.rightBarButtonItems = [filterButton, notificationButton]
    }
    
    @objc func reLoadView() {
        let newViewController = HomeViewController()
        self.navigationController?.setViewControllers([newViewController], animated: false)
    }

    @objc func tappedFilterButton() {
        let viewController = HomeFilterViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func tappedNotificationButton() {
        let viewController = NotificationViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}
