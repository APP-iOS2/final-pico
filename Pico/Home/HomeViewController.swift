//
//  ViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import SnapKit
import SwiftUI

final class HomeViewController: UIViewController {
    
    private let navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar()
        return navigationBar
    }()
    
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
    
    func configNavigationBarItem() {
        let notificationImage = UIImage(systemName: "bell.fill")
        let filterImage = UIImage(systemName: "slider.horizontal.3")
        
        let notificationButton = UIBarButtonItem(image: notificationImage, style: .plain, target: nil, action: nil)
        let filterButton = UIBarButtonItem(image: filterImage, style: .plain, target: nil, action: nil)
        
        notificationButton.tintColor = .darkGray
        filterButton.tintColor = .darkGray
        navigationItem.rightBarButtonItems = [filterButton, notificationButton]
    }
    
    func addSubView() {
        view.addSubview(navigationBar)
        
    }
    
    func makeConstraints() {
        
    }
    
    func addTabImageViewController() {
        let tabImageViewController = HomeTabImageViewController(name: "윈터", age: "24")
        addChild(tabImageViewController)
        view.addSubview(tabImageViewController.view)
        tabImageViewController.didMove(toParent: self)
    }
}
