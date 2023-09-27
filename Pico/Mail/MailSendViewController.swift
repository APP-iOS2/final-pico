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
        navigationBar.barTintColor = .systemBackground
        return navigationBar
    }()
    
    private let navItem: UINavigationItem = {
        let navigationItem = UINavigationItem(title: "쪽지 보내기")
        return navigationItem
    }()
    
    private let leftBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: nil, action: #selector(tappedBackButton))
        barButtonItem.tintColor = .picoBlue
        return barButtonItem
    }()
    
    private let receiverStack = UIStackView()
    
    private let receiverLabel: UILabel = {
        let label = UILabel()
        label.text = "상대"
        label.textAlignment = .center
        label.font = UIFont.picoContentFont
        label.textColor = .picoFontBlack
        return label
    }()
    
    private let receiverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let receiverNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.picoContentBoldFont
        label.textColor = .picoFontBlack
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        addViews()
        makeConstraints()
        configNavigationBarItem()
    }
    
    override func viewDidLayoutSubviews() {
        picoVcSetCircleImageView(imageView: receiverImageView)
    }
    
    func configNavigationBarItem() {
        
        navItem.leftBarButtonItem = leftBarButton
        navigationBar.setItems([navItem], animated: true)
    }
    
    private func addViews() {
        
        [receiverLabel, receiverImageView, receiverNameLabel].forEach { view in
            receiverStack.addSubview(view)
        }
        
        view.addSubview(navigationBar)
        view.addSubview(receiverStack)
    }
    
    private func makeConstraints() {
        
        let safeArea = view.safeAreaLayoutGuide
        
        navigationBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeArea)
        }
        
        receiverStack.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom).offset(20)
            make.leading.trailing.equalTo(navigationBar).offset(20)
        }
        
        receiverLabel.snp.makeConstraints { make in
            make.leading.equalTo(receiverStack)
            make.centerY.equalTo(receiverImageView.snp.centerY)
            make.width.equalTo(35)
        }
        
        receiverImageView.snp.makeConstraints { make in
            make.top.equalTo(receiverStack)
            make.leading.equalTo(receiverLabel.snp.trailing).offset(20)
            make.width.height.equalTo(50)
        }
        
        receiverNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(receiverImageView.snp.trailing).offset(15)
            make.trailing.equalTo(receiverStack)
            make.centerY.equalTo(receiverImageView.snp.centerY)
        }
    }
    
    @objc func tappedBackButton() {
        dismiss(animated: true)
    }
    
    func getReceiver(image: String, name: String) {
        if let imageURL = URL(string: image) {
            receiverImageView.load(url: imageURL)
        }
        receiverNameLabel.text = name
    }
}
