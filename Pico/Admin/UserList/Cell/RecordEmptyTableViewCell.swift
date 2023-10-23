//
//  RecordEmptyTableViewCell.swift
//  Pico
//
//  Created by 최하늘 on 10/21/23.
//

import UIKit
import SnapKit

final class RecordEmptyTableViewCell: UITableViewCell {
    
    private let chuImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "magnifier"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var infomationLabel: UILabel = {
        let label = UILabel()
        label.text = "기록이 없습니다."
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addViews()
        makeConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews() {
        contentView.addSubview([chuImageView, infomationLabel])
    }
    
    private func makeConstraints() {
        chuImageView.snp.makeConstraints { make in
            make.top.equalTo(50)
            make.centerX.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(120)
        }

        infomationLabel.snp.makeConstraints { make in
            make.top.equalTo(chuImageView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().offset(-100)
        }
    }
}
