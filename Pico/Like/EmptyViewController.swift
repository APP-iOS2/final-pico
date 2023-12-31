//
//  LikeEmptyView.swift
//  Pico
//
//  Created by 방유빈 on 2023/09/25.
//

import UIKit
import SnapKit

final class EmptyViewController: UIViewController {
    enum EmptyViewType: String {
        case iLikeU = "누른 Like가 표시됩니다."
        case uLikeMe = "받은 Like가 표시됩니다."
        case message = "마음의 드는 분과 대화를 나눠보세요."
        case notification = "도착한 알림이 없습니다."
    }
    
    private var viewType: EmptyViewType = .message
    
    private let contentsView = UIView()
    
    private let typeImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var infomationLabel: UILabel = {
        let label = UILabel()
        label.text = viewType.rawValue
        label.textColor = .picoFontGray
        label.textAlignment = .center
        return label
    }()
    
    lazy var linkButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.setTitle("둘러보기 >", for: .normal)
        button.setTitleColor(.picoFontGray, for: .normal)
        button.tintColor = .clear
        button.addTarget(self, action: #selector(tappedLinkButton), for: .touchUpInside)
        return button
    }()
    
    private var messageSubLabel: UILabel = {
        let label = UILabel()
        label.text = "서로 좋아요가 연결되는 순간 채팅 가능~"
        label.textColor = .picoFontGray
        return label
    }()
    
    convenience init(type: EmptyViewType) {
        self.init()
        self.viewType = type
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        makeConstraints()
        configImage()
    }
    
    private func configImage() {
        let config = UIImage.SymbolConfiguration(pointSize: 30)
        switch viewType {
        case .iLikeU:
            typeImage.image = UIImage(systemName: "heart.fill", withConfiguration: config)
        case .uLikeMe:
            typeImage.image = UIImage(systemName: "heart.fill", withConfiguration: config)
        case .message:
            typeImage.image = UIImage(systemName: "message.fill", withConfiguration: config)
        case .notification:
            typeImage.image = UIImage(systemName: "bell.fill", withConfiguration: config)
        }
        typeImage.tintColor = .picoGray
    }
    
    @objc func tappedLinkButton(_ sender: UIButton) {
        if let tabBarController = self.tabBarController as? TabBarController {
            tabBarController.selectedIndex = 0
            
            if let navigationController = tabBarController.viewControllers?[0] as? UINavigationController {
                navigationController.popToRootViewController(animated: true)
            }
        }
    }
    
    private func addViews() {
        view.addSubview(contentsView)
        contentsView.addSubview([typeImage, infomationLabel])
        if viewType == .iLikeU {
            contentsView.addSubview(linkButton)
        }
        if viewType == .message {
            contentsView.addSubview(messageSubLabel)
        }
    }
    
    private func makeConstraints() {
        contentsView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        typeImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(70)
            make.centerX.equalToSuperview()
        }
        
        infomationLabel.snp.makeConstraints { make in
            make.top.equalTo(typeImage.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        if viewType == .iLikeU {
            linkButton.snp.makeConstraints { make in
                make.top.equalTo(infomationLabel.snp.bottom).offset(10)
                make.centerX.equalTo(infomationLabel)
            }
        }
        
        if viewType == .message {
            messageSubLabel.snp.makeConstraints { make in
                make.top.equalTo(infomationLabel.snp.bottom).offset(10)
                make.centerX.equalTo(infomationLabel)
            }
        }
    }
}
