//
//  LikeViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import SnapKit

final class LikeViewController: BaseViewController {
    private let viewControllers = [LikeMeViewController(), LikeUViewController()]
    
    private let tabSegmentedControl: UISegmentedControl = {
        let segment = UISegmentedControl()
        segment.selectedSegmentTintColor = .clear
        segment.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        segment.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        segment.insertSegment(withTitle: "U Like Me?", at: 0, animated: true)
        segment.insertSegment(withTitle: "I Like U !", at: 1, animated: true)
        segment.selectedSegmentIndex = 0
        let font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        segment.setTitleTextAttributes([NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: UIColor.gray], for: .normal)
        segment.setTitleTextAttributes([NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: UIColor.picoFontBlack], for: .selected)
        return segment
    }()
    
    private let underLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .picoFontBlack
        return view
    }()
    
    private let segmentView: UIView = {
        let view = UIView()
        view.configBackgroundColor()
        return view
    }()
    
    private let contentsView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var pageViewController: UIPageViewController = {
        let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageController.view.frame = contentsView.frame
        return pageController
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configBarItem()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        makeConstraints()
        configTabBar()
        configBarItem()
    }
    
    private func configTabBar() {
        tabSegmentedControl.addTarget(self, action: #selector(changeUnderLinePosition), for: .valueChanged)
        
        pageViewController.setViewControllers([viewControllers[tabSegmentedControl.selectedSegmentIndex]], direction: .reverse, animated: true)
        
        self.addChild(pageViewController)
    }
    
    private func configBarItem() {
        let notiButton = UIBarButtonItem(image: UIImage(systemName: "bell.fill"), style: .done, target: self, action: #selector(tappedNotiButton))
        notiButton.tintColor = .darkGray
        notiButton.accessibilityLabel = "알림"
        navigationItem.rightBarButtonItem = notiButton
    }
    
    @objc private func tappedNotiButton(_ sender: UIBarButtonItem) {
        let notificationViewController = NotificationViewController()
        notificationViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(notificationViewController, animated: true)
    }
    
    @objc private func changeUnderLinePosition() {
        let segmentIndex = CGFloat(tabSegmentedControl.selectedSegmentIndex)
        
        let segmentWidth = tabSegmentedControl.frame.width / CGFloat(tabSegmentedControl.numberOfSegments)
        let leadingDistance = segmentWidth * segmentIndex
        underLineView.snp.updateConstraints({ make in
            make.leading.equalTo(tabSegmentedControl).offset(leadingDistance)
        })
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
        pageViewController.setViewControllers([viewControllers[tabSegmentedControl.selectedSegmentIndex]], direction: segmentIndex == 1.0 ? .forward : .reverse, animated: true)
        
    }
    
    private func addViews() {
        segmentView.addSubview([tabSegmentedControl, underLineView])
        view.addSubview([segmentView, contentsView])
        contentsView.addSubview([pageViewController.view])
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        segmentView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeArea)
            make.height.equalTo(40)
        }
        
        tabSegmentedControl.snp.makeConstraints { make in
            make.top.leading.centerX.centerY.equalTo(segmentView)
        }
        
        contentsView.snp.makeConstraints { make in
            make.top.equalTo(segmentView.snp.bottom)
            make.leading.trailing.equalTo(segmentView)
            make.bottom.equalTo(safeArea)
        }
        
        underLineView.snp.makeConstraints { make in
            make.leading.bottom.equalTo(tabSegmentedControl)
            make.width.equalTo(tabSegmentedControl.snp.width).multipliedBy(1 / CGFloat(tabSegmentedControl.numberOfSegments))
            make.height.equalTo(2)
        }
    }
}
