//
//  DetailViewController.swift
//  Pico
//
//  Created by 신희권 on 2023/09/25.
//

import UIKit
import SnapKit

final class DetailViewController: UIViewController {
    private let topViewController = TopUserDetailViewController()
    private let middleViewController = MiddleUserDetailViewController()
    private let bottomViewController = BottomUserDetailViewController()
    
    private let navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar()
        navigationBar.barTintColor = .systemBackground
        return navigationBar
    }()
    
    private let navItem: UINavigationItem = {
        let navigationItem = UINavigationItem(title: "카리나, 24")
        return navigationItem
    }()
    
    private let leftBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .plain, target: DetailViewController.self, action: #selector(tappedNavigationButton))
        barButtonItem.tintColor = .black
        return barButtonItem
    }()
    
    private let rightBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: DetailViewController.self, action: #selector(tappedNavigationButton))
        barButtonItem.tintColor = .black
        return barButtonItem
    }()
    
    private let separatorView: UIView = {
        let uiView = UIView()
        uiView.backgroundColor = .systemGray5
        return uiView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addViews()
        addChilds()
        makeConstraints()
        configureNavigationBar()
    }
    
    @objc func tappedNavigationButton() {
        // Action
    }
    
    private func configureNavigationBar() {
        navItem.leftBarButtonItem = leftBarButton
        navItem.rightBarButtonItem = rightBarButton
        navigationBar.setItems([navItem], animated: true)
    }
    
    final private func addChilds() {
        [topViewController, middleViewController, bottomViewController].forEach { self.addChild($0) }
    }
    
    final private func addViews() {
        [navigationBar, separatorView, topViewController.view, middleViewController.view, bottomViewController.view].forEach {
            view.addSubview($0)
        }
    }
    
    final private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        navigationBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeArea)
        }
        
        topViewController.view.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.leading.trailing.equalTo(safeArea)
            make.height.equalTo(Screen.height / 2)
        }
        
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(topViewController.view.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(10)
        }
        
        middleViewController.view.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom)
            make.leading.trailing.equalTo(safeArea)
            make.height.equalTo(Screen.height / 3)
        }
        
        bottomViewController.view.snp.makeConstraints { make in
            make.top.equalTo(middleViewController.view.snp.bottom)
            make.leading.trailing.equalTo(safeArea)
            make.bottom.equalToSuperview()
            
        }
    }
}
