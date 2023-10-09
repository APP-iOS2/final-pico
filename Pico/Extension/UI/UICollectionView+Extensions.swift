//
//  UICollectionView+Extensions.swift
//  Pico
//
//  Created by 방유빈 on 2023/10/10.
//

import UIKit

extension UICollectionReusableView: Reusable { }

extension UICollectionView {
    func cellForItem<T: UICollectionViewCell>(atIndexPath indexPath: IndexPath) -> T {
        guard
            let cell = cellForItem(at: indexPath) as? T
        else {
            fatalError("Could not cellForItemAt at indexPath: \(T.reuseIdentifier)")
        }

        return cell
    }

    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard
            let cell = dequeueReusableCell(
                withReuseIdentifier: T.reuseIdentifier,
                for: indexPath
            ) as? T
        else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }

    func register<T>(
        cell: T.Type
    ) where T: UICollectionViewCell {
        register(cell, forCellWithReuseIdentifier: cell.reuseIdentifier)
    }
}
