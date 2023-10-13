//
//  RecordHeaderCollectionView.swift
//  Pico
//
//  Created by 최하늘 on 10/13/23.
//

import UIKit

final class RecordHeaderCollectionView: UICollectionView {
    
    var buttonWidth: CGFloat = 20.0
    var buttonHeight: CGFloat = 20.0
    var numberOfButtons: Int = 20
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        super.init(frame: .zero, collectionViewLayout: layout)
        self.backgroundColor = .clear
        self.showsHorizontalScrollIndicator = false
        self.register(ButtonCollectionViewCell.self, forCellWithReuseIdentifier: "ButtonCell")
        self.dataSource = self
        self.delegate = self
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RecordHeaderCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfButtons
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonCell", for: indexPath) as! ButtonCollectionViewCell
        // Customize the button inside the cell
        cell.button.setTitle("Button \(indexPath.item)", for: .normal)
        cell.button.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)
        return cell
    }
}

extension RecordHeaderCollectionView: UICollectionViewDelegate {
    // Handle interactions with the buttons here
}

final class ButtonCollectionViewCell: UICollectionViewCell {
    var button = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(button)
        button.setTitleColor(.black, for: .normal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
