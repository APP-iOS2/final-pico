//
//  SwitchButton.swift
//  Pico
//
//  Created by 김민기 on 2023/10/04.
//

import UIKit
import SnapKit

final class SwitchButton: UIButton {
    
    private lazy var barView: UIView = {
        let view = UIView()
        view.backgroundColor = .picoGray
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var circleView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.masksToBounds = true
        return view
    }()
    
    private var isOnSwitch: Bool = false {
        didSet {
            self.changeState()
        }
    }
    
    private var animationDuration: TimeInterval = 0.25
    private var isAnimated: Bool = false
    private var viewframe: CGRect = CGRect()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        makeConstraints(frame: frame)
        configView(frame: frame)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func addViews() {
        [barView, circleView].forEach {
            addSubview($0)
        }
    }
    private func makeConstraints(frame: CGRect) {
        barView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(3)
            make.leading.trailing.equalToSuperview()
        }
        
        circleView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.height.equalTo(frame.width)
        }
    }
    
    private func configView(frame: CGRect) {
        viewframe = frame
        barView.layer.cornerRadius = (frame.width / 2) - 3
        circleView.layer.cornerRadius = frame.width / 2
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.setOn(onSwitch: !self.isOnSwitch, animated: true)
    }
    
    private func setOn(onSwitch: Bool, animated: Bool) {
        self.isAnimated = animated
        self.isOnSwitch = onSwitch
    }
    
    private func changeState() {
        let duration = self.isAnimated ? self.animationDuration : 0
        
        UIView.animate(withDuration: duration, animations: { [weak self] in
            guard let self = self else { return }
            if self.isOnSwitch {
                circleView.snp.remakeConstraints { make in
                    make.top.bottom.equalToSuperview()
                    make.trailing.equalToSuperview()
                    make.width.height.equalTo(self.viewframe.width)
                }
                self.barView.backgroundColor = .picoBlue
            } else {
                circleView.snp.remakeConstraints { make in
                    make.top.bottom.equalToSuperview()
                    make.leading.equalToSuperview()
                    make.width.height.equalTo(self.viewframe.width)
                }
                self.barView.backgroundColor = .picoGray
            }
            self.layoutIfNeeded()
        }, completion: { [weak self] _ in
            guard let self = self else { return }
            self.isAnimated = false
        })
    }
}
