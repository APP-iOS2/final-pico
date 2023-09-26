//
//  MailSendViewController.swift
//  Pico
//
//  Created by 양성혜 on 2023/09/26.
//

import UIKit
import SnapKit

final class MailSendViewController: UIViewController {
    
    private let navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar()
        return navigationBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        configNavigationBarItem()
        addViews()
        makeConstraints()
    }
    
    func configNavigationBarItem() {
        
        let backImage = UIImage(systemName: "chevron.backward")
        let paperplaneImage = UIImage(systemName: "paperplane.fill")

        let backButton = UIBarButtonItem(image: backImage, style: .plain, target: nil, action: nil)
        let sendButton = UIBarButtonItem(image: paperplaneImage, style: .plain, target: nil, action: nil)
        backButton.tintColor = .picoBlue
        sendButton.tintColor = .picoBlue
        
        navigationItem.title = "쪽지 보내기"
        navigationItem.leftBarButtonItems = [backButton]
        navigationItem.rightBarButtonItems = [sendButton]
    }
    
    private func addViews() {
        self.view.addSubview(navigationBar)
    }
    
    private func makeConstraints() {
        
    }
       
}
