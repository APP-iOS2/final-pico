//
//  LoadImageView.swift
//  Pico
//
//  Created by 양성혜 on 2023/09/26.
//

import UIKit

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    self?.image = UIImage(data: data)
                }
                
            } else {
                DispatchQueue.main.async {
                    self?.image = UIImage(named: "chu")
                }
            }
        }
    }
}
