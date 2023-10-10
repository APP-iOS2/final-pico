//
//  StoreTableCell.swift
//  Pico
//
//  Created by 김민기 on 2023/09/26.
//

import UIKit

final class StoreTableCell: UITableViewCell {
    
    private let tableImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "chu")
        return imageView
    }()
    private let countLabel: UILabel = {
        let label = UILabel()
        label.textColor = .picoFontBlack
        label.font = UIFont.picoTitleFont
        return label
    }()
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .picoFontBlack
        label.font = UIFont.picoSubTitleFont
        return label
    }()
    private let discountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont.picoDescriptionFont
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubView()
        makeConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(count: String, price: String, discount: String?) {
        countLabel.text = "X \(count)"
        priceLabel.text = "\(price) 원"
        guard let discount else { return }
        discountLabel.text = "- \(discount)%"
    }
    
    private func addSubView() {
        [tableImageView, countLabel, priceLabel, discountLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        tableImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.height.width.equalTo(80)
        }
        countLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(tableImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        priceLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-15)
        }
        discountLabel.snp.makeConstraints { make in
            make.trailing.equalTo(priceLabel.snp.trailing)
            make.bottom.equalTo(priceLabel.snp.top).offset(-10)
        }
    }
}
