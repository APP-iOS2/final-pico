//
//  ViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import SnapKit

final class HomeViewController: UIViewController {
    
    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configLogoBarItem()
        configNavigationBarItem()
        addSubView()
        makeConstraints()
        addTabImageViewController()
    }
    
    private func configNavigationBarItem() {
        let filterImage = UIImage(systemName: "slider.horizontal.3")
        let filterButton = UIBarButtonItem(image: filterImage, style: .plain, target: self, action: #selector(tappedFilterButton))
        filterButton.tintColor = .darkGray
        
        let notificationImage = UIImage(systemName: "bell.fill")
        let notificationButton = UIBarButtonItem(image: notificationImage, style: .plain, target: nil, action: nil)
        notificationButton.tintColor = .darkGray
        
        navigationItem.rightBarButtonItems = [filterButton, notificationButton]
    }
    
    private func addSubView() {
        
    }
    
    private func makeConstraints() {
        
    }
    
    private func addTabImageViewController() {
        let tabImageViewController = HomeTabImageViewController(name: "윈터", age: "24")
        addChild(tabImageViewController)
        view.addSubview(tabImageViewController.view)
        tabImageViewController.didMove(toParent: self)
    }
    
    @objc func tappedFilterButton() {
        let viewController = HomeFilterViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }

}
