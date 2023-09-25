//
//  LikeEmptyView.swift
//  Pico
//
//  Created by 방유빈 on 2023/09/25.
//

import UIKit
import SnapKit

class LikeEmptyView: UIView {
    enum EmptyViewType: String {
        case iLikeU = "받은 Like가 표시됩니다."
        case uLikeMe = "누른 Like가 표시됩니다."
    }
    
    private var viewType: EmptyViewType
    
    let chuImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "chu"))
        
        return imageView
    }()
    
    lazy var infomationLabel: UILabel = {
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
        
        return button
    }()
    
    convenience init(frame: CGRect, type: EmptyViewType) {
        self.init(frame: frame)
        self.viewType = type
        addViews()
        makeConstraints()
    }
    
    override init(frame: CGRect) {
        self.viewType = .iLikeU
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews() {
        [chuImage, infomationLabel].forEach { item in
            addSubview(item)
        }
        if viewType == .uLikeMe {
            addSubview(linkButton)
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
        
        if viewType == .uLikeMe {
            linkButton.snp.makeConstraints { make in
                make.top.equalTo(infomationLabel.snp.bottom).offset(10)
                make.centerX.equalTo(infomationLabel)
            }
        }
    }
}
