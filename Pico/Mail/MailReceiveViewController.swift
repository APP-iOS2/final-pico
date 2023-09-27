//
//  MailReceiveViewController.swift
//  Pico
//
//  Created by 양성혜 on 2023/09/26.
//

import UIKit
import SnapKit

final class MailReceiveViewController: UIViewController {
    
    private let navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar()
        navigationBar.barTintColor = .systemBackground
        return navigationBar
    }()
    
    private let navItem: UINavigationItem = {
        let navigationItem = UINavigationItem(title: "쪽지 보내기")
        return navigationItem
    }()
    
    private let leftBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: MailSendViewController.self, action: #selector(tappedNavigationButton))
        barButtonItem.tintColor = .picoBlue
        return barButtonItem
    }()
    
    private let rightBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "paperplane.fill"), style: .plain, target: MailSendViewController.self, action: #selector(tappedNavigationButton))
        barButtonItem.tintColor = .picoBlue
        return barButtonItem
    }()
    
    private let religionLabel: UILabel = {
        let label = UILabel()
        label.text = "불교"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        addViews()
        makeConstraints()
        //configLogoBarItem()
        configNavigationBarItem()
    }
    
    func configNavigationBarItem() {
        
        navItem.leftBarButtonItem = leftBarButton
        navItem.rightBarButtonItem = rightBarButton
        navigationBar.setItems([navItem], animated: true)
    }
    
    private func addViews() {
        view.addSubview(navigationBar)
        view.addSubview(religionLabel)
    }
    
    private func makeConstraints() {
        
        let safeArea = view.safeAreaLayoutGuide
        navigationBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeArea)
        }
        religionLabel.snp.makeConstraints { make in
            make.centerX.equalTo(safeArea.snp.centerX)
            make.centerY.equalTo(safeArea.snp.centerY)
        }
    }
    
    @objc func tappedNavigationButton() {
        // Action
    }
}
