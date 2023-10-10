//
//  ProfileEditTableHeaderView.swift
//  Pico
//
//  Created by 김민기 on 2023/09/27.
//

import UIKit

final class ProfileEditTableHeaderView: UITableViewHeaderFooterView {
    
    private let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.font = .picoDescriptionFont
        label.textColor = .picoFontGray
        label.text = "추가 정보"
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubView()
        makeConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(headerLabel: String) {
        self.headerLabel.text = headerLabel
    }
    
    private func addSubView() {
        [borderView, headerLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        borderView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-15)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        headerLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
    }
}
