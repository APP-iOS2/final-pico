//
//  ProfileEditLoactionTabelCell.swift
//  Pico
//
//  Created by 김민기 on 2023/09/27.
//

import UIKit

final class ProfileEditLoactionTabelCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .picoFontBlack
        label.font = UIFont.picoSubTitleFont
        label.text = "내 위치"
        return label
    }()
    
    private lazy var locationChangeButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "chu")?.resized(toSize: CGSize(width: 30, height: 30))
        var configuration = UIButton.Configuration.plain()
        configuration.subtitle = "경기도 용인시"
        configuration.image = image
        configuration.imagePlacement = .leading
        configuration.imagePadding = 3
      
        button.configuration = configuration
        button.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubView()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func tappedButton() {
        print("tap")
    }
    
    private func addSubView() {
        [titleLabel, locationChangeButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        
        locationChangeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
    }
}
