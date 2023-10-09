//
//  UITableView+Extensions.swift
//  Pico
//
//  Created by 최하늘 on 10/10/23.
//

import UIKit

protocol Reusable: AnyObject {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: Reusable { }

extension UITableViewHeaderFooterView: Reusable { }

extension UITableView {
    func cellForRow<T: UITableViewCell>(atIndexPath indexPath: IndexPath) -> T {
        guard
            let cell = cellForRow(at: indexPath) as? T
        else {
            fatalError("Could not cellForItemAt at \(T.reuseIdentifier) cell")
        }
        
        return cell
    }
    
    func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(
            withIdentifier: T.reuseIdentifier,
            for: indexPath
        ) as? T else {
            fatalError("Fail to dequeue: \(T.reuseIdentifier) cell")
        }
        return cell
    }
    
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>() -> T {
        guard let cell = dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as? T else {
            fatalError("Fail to dequeue: \(T.reuseIdentifier) cell")
        }
        return cell
    }
    
    func register<T>(
        cell: T.Type,
        forCellReuseIdentifier reuseIdentifier: String = T.reuseIdentifier
    ) where T: UITableViewCell {
        register(cell, forCellReuseIdentifier: reuseIdentifier)
    }
    
    func register<T>(
        headerFooterView: T.Type,
        forCellReuseIdentifier reuseIdentifier: String = T.reuseIdentifier
    ) where T: UITableViewHeaderFooterView {
        register(headerFooterView, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
    }
}
