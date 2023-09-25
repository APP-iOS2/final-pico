//
//  LikeViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import SnapKit

final class LikeViewController: UIViewController {
    private let viewControllers = [LikeUViewController(), LikeMeViewController()]
    
    private let tabSegmentedControl: UISegmentedControl = {
        let segment = UISegmentedControl()
        segment.selectedSegmentTintColor = .clear
        segment.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        segment.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        let font = UIFont.systemFont(ofSize: 16, weight: .bold)          // Compute the right size
        segment.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        segment.insertSegment(withTitle: "I Like U !", at: 0, animated: true)
        segment.insertSegment(withTitle: "U Like Me?", at: 1, animated: true)
        
        segment.selectedSegmentIndex = 0
        
        return segment
    }()

    private let underLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        
        return view
    }()
    
    private let segmentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        return view
    }()
    
    private let contentsView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    lazy var pageViewController: UIPageViewController = {
        let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageController.view.frame = contentsView.frame
        
        return pageController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addViews()
        makeConstraints()
        configurePageView()
        tabSegmentedControl.addTarget(self, action: #selector(changeUnderLinePosition), for: .valueChanged)
    }
    
    private func addViews() {
        [tabSegmentedControl, underLineView].forEach { item in
            segmentView.addSubview(item)
            item.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [segmentView, contentsView].forEach { item in
            view.addSubview(item)
            item.translatesAutoresizingMaskIntoConstraints = false
        }
        contentsView.addSubview(pageViewController.view)
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        segmentView.snp.makeConstraints { make in
            make.leading.top.trailing.equalTo(safeArea)
            make.height.equalTo(40)
        }
        
        tabSegmentedControl.snp.makeConstraints { make in
            make.top.leading.centerX.centerY.equalTo(segmentView)
        }
        
        contentsView.snp.makeConstraints { make in
            make.bottom.equalTo(safeArea)
            make.leading.trailing.equalTo(segmentView)
            make.top.equalTo(segmentView.snp.bottom)
        }

        underLineView.snp.makeConstraints { make in
            make.height.equalTo(2)
            make.bottom.equalTo(tabSegmentedControl)
            make.leading.equalTo(tabSegmentedControl)
            make.width.equalTo(tabSegmentedControl.snp.width).multipliedBy(1 / CGFloat(tabSegmentedControl.numberOfSegments))
        }
    }
    
    private func configurePageView() {
        pageViewController.setViewControllers([viewControllers[tabSegmentedControl.selectedSegmentIndex]], direction: .reverse, animated: true)
        
        self.addChild(pageViewController)
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
}
