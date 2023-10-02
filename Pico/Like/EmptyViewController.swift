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
    }
    
    private var viewType: EmptyViewType = .message
    
    private let chuImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "chu"))
        return imageView
    }()
    
    private lazy var infomationLabel: UILabel = {
        let label = UILabel()
        label.text = viewType.rawValue
        label.textAlignment = .center
        return label
    }()
    
    lazy var linkButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.setTitle("둘러보기 >", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.tintColor = .clear
        button.addTarget(self, action: #selector(tappedLinkButton), for: .touchUpInside)
        return button
    }()
    
    private var messageSubLabel: UILabel = {
        let label = UILabel()
        label.text = "서로 좋아요가 연결되는 순간 채팅 가능~"
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
        [chuImage, infomationLabel].forEach { item in
            view.addSubview(item)
        }
        if viewType == .iLikeU {
            view.addSubview(linkButton)
        }
        if viewType == .message {
            view.addSubview(messageSubLabel)
        }
    }
    
    private func makeConstraints() {
        chuImage.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.size.equalTo(Screen.width * 0.5)
        }
        
        infomationLabel.snp.makeConstraints { make in
            make.top.equalTo(chuImage.snp.bottom).offset(10)
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
