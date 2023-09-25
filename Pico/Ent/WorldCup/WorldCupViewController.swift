//
//  WorldCupViewController.swift
//  Pico
//
//  Created by 오영석 on 2023/09/25.
//

import UIKit
import SnapKit

final class WorldCupViewController: UIViewController {
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "WorldCup"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addViews()
        setLayoutConstraints()
    }
    
    func addViews() {
        [backgroundImageView].forEach { item in
            view.addSubview(item)
        }
    }
    
    func setLayoutConstraints() {
        let padding: CGFloat = 20
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
