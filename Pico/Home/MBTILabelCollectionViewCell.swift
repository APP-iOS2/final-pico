//
//  MBTILabelCollectionViewCell.swift
//  Pico
//
//  Created by 임대진 on 2023/09/27.
//

import UIKit

final class MBTILabelCollectionViewCell: UICollectionViewCell {
    
    private var filterChangeState: Bool = false
    private let mbtiButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = .picoGray
        layer.cornerRadius = 10
        clipsToBounds = true
        
        addSubview(mbtiButton)
        mbtiButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    private func updateButtonAppearance() {
        if let buttonText = mbtiButton.titleLabel?.text?.lowercased(), let mbti = MBTIType(rawValue: buttonText) {
            backgroundColor = mbtiButton.isSelected ? UIColor(hex: mbti.colorName) : .picoGray
        }
    }
    
    func configureWithMBTI(_ mbti: MBTIType) {
        mbtiButton.setTitle(mbti.rawValue.uppercased(), for: .normal)
        mbtiButton.titleLabel?.font = .picoMBTILabelFont
        mbtiButton.isSelected = HomeViewModel.filterMbti.contains(mbti)
        backgroundColor = mbtiButton.isSelected ? UIColor(hex: mbti.colorName) : .picoGray
        mbtiButton.isUserInteractionEnabled = true
        mbtiButton.addTarget(self, action: #selector(buttonTouch), for: .touchUpInside)
    }
//    private func updateButtonAppearance(_ button: UIButton) {
//        guard let mbti = button.titleLabel?.text?.lowercased() as? MBTIType else { return }
//        button.setTitleColor(button.isSelected ? .white : .picoFontGray, for: .normal)
//    }
    @objc func buttonTouch() {
        mbtiButton.isSelected.toggle()
        if let buttonText = mbtiButton.titleLabel?.text?.lowercased(), let mbti = MBTIType(rawValue: buttonText) {
            backgroundColor = mbtiButton.isSelected ? UIColor(hex: mbti.colorName) : .picoGray
            if mbtiButton.isSelected {
                HomeViewModel.filterMbti.append(mbti)
                
                let mbtiData = try? JSONEncoder().encode(HomeViewModel.filterMbti)
                UserDefaults.standard.set(mbtiData, forKey: UserDefaultsManager.Key.filterMbti.rawValue)
                
            } else {
                if let index = HomeViewModel.filterMbti.firstIndex(of: mbti) {
                    HomeViewModel.filterMbti.remove(at: index)
                    
                    let mbtiData = try? JSONEncoder().encode(HomeViewModel.filterMbti)
                    UserDefaults.standard.set(mbtiData, forKey: UserDefaultsManager.Key.filterMbti.rawValue)
                }
            }
            HomeFilterViewController.filterChangeState = true
        }
    }
}
