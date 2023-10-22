//
//  ProfileEditNicknameTabelCell.swift
//  Pico
//
//  Created by 김민기 on 2023/09/26.
//

import UIKit

protocol ProfileEditNicknameDelegate: AnyObject {
    func presentEditView()
}

final class ProfileEditNicknameTabelCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .picoFontBlack
        label.font = UIFont.picoSubTitleFont
        label.text = "닉네임 변경"
        return label
    }()
    
    private lazy var nicknameChangeButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "chu")?.resized(toSize: CGSize(width: 30, height: 30))
        var configuration = UIButton.Configuration.plain()
        configuration.image = image
        configuration.imagePlacement = .leading
        configuration.imagePadding = 3
        configuration.subtitle = "50"
        button.configuration = configuration
        button.layer.masksToBounds = false
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.picoBlue.cgColor
        button.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
        return button
    }()
    
    weak var profileEditNicknameDelegate: ProfileEditNicknameDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubView()
        makeConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func tappedButton() {
        profileEditNicknameDelegate?.presentEditView()
    }
    
    private func addSubView() {
        [titleLabel, nicknameChangeButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        
        nicknameChangeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
    }
}
