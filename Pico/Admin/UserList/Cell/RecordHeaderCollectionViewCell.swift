//
//  RecordHeaderCollectionViewCell.swift
//  Pico
//
//  Created by 최하늘 on 10/13/23.
//

import UIKit
import SnapKit

final class RecordHeaderCollectionViewCell: UICollectionViewCell {
    
    enum HeaderType {
        case main
        case sub
        
        var textColor: (UIColor, UIColor) {
            switch self {
            case .main:
                return (.picoFontBlack, .picoGray)
            case .sub:
                return (.picoFontGray, .picoGray)
            }
        }
        
        var font: (UIFont, UIFont) {
            switch self {
            case .main:
                return (.picoSubTitleFont, .picoContentFont)
            case .sub:
                return (.picoSubTitleSmallFont, .picoContentFont)
            }
        }
    }
    
    private let view: UIView = UIView()
    private let label: UILabel = UILabel()
    
//    let headerType =
    var isSelectedCell: Bool = false {
        didSet {
            label.textColor = isSelectedCell ? .picoFontBlack : .picoGray
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
