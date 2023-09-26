//
//  BottomUserDetailViewController.swift
//  Pico
//
//  Created by 신희권 on 2023/09/26.
//

import UIKit
import SnapKit

class BottomUserTableViewCell: UITableViewCell {
    static let id = "bottomCell"
    var hobbyArray: [String] = ["노래하기", "춤추기", "감사합니다", "감사합니다", "감사합니다", "감사합니다", "감사합니다"]
    private var hobbylabelArray: [UILabel] = []
    
    private let hobbyLabel: UILabel = {
        let label = UILabel()
        label.text = "내 취미"
        label.font = UIFont.picoSubTitleFont
        return label
    }()
    
    private let personalLabel: UILabel = {
        let label = UILabel()
        label.text = "내 성격"
        label.font = UIFont.picoSubTitleFont
        return label
    }()
    
    private let hobbyStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addViews()
        makeConstraints()
        configHobbyLabels()
        
    }
    
    private func configHobbyLabels() {
        for hobby in hobbyArray {
            let label = UILabel()
            label.text = hobby
            label.layer.cornerRadius = 10
            label.backgroundColor = .picoGray
            label.sizeToFit()
            self.addSubview(label)
            hobbylabelArray.append(label)
        }
        
        for (index, label) in hobbylabelArray.enumerated() {
            label.snp.makeConstraints { make in
                make.top.equalTo(hobbyLabel.snp.bottom).offset(10)
                make.leading.equalTo(hobbyLabel.snp.leading).offset(index * 60)
                make.trailing.equalToSuperview()
            }
        }
    }
    
    final private func addViews() {
        [hobbyLabel, personalLabel, hobbyStack].forEach {
            self.addSubview($0)
        }
        for label in hobbylabelArray {
            hobbyStack.addSubview(label)
        }
    }
    
    final private func makeConstraints() {
        hobbyLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
