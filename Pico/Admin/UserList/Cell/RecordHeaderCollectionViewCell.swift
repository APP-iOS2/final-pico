//
//  RecordHeaderCollectionViewCell.swift
//  Pico
//
//  Created by 최하늘 on 10/13/23.
//

import UIKit
import SnapKit

final class RecordHeaderCollectionViewCell: UICollectionViewCell {
    
    private let view: UIView = {
       let view = UIView()
        view.layer.cornerRadius = 15
        return view
    }()
    private let label: UILabel = UILabel()
    
    var isSelectedCell: Bool = false {
        didSet {
            view.backgroundColor = isSelectedCell ? .systemGray6 : .clear
            label.textColor = isSelectedCell ? .picoFontBlack : .picoFontGray
            label.font = isSelectedCell ? .picoSubTitleFont : .picoContentFont
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        makeConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(text: String) {
        label.text = text
    }
    
    private func addViews() {
        contentView.addSubview(view)
        view.addSubview(label)
    }
    
    private func makeConstraints() {
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
