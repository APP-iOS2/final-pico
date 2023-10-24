//
//  AdminViewController.swift
//  Pico
//
//  Created by 최하늘 on 10/11/23.
//

import UIKit
import SnapKit

final class AdminViewController: AdminBaseViewController {
    
    private let viewControllers = [
        UINavigationController(rootViewController: AdminUserViewController(viewModel: AdminUserViewModel())),
        UINavigationController(rootViewController: AdminReportViewController(viewModel: AdminReportViewModel()))
    ]
    
    private let tabSegmentedControl: UISegmentedControl = {
        let segment = UISegmentedControl()
        segment.selectedSegmentTintColor = .clear
        segment.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        segment.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        segment.insertSegment(withTitle: "회원 목록", at: 0, animated: true)
        segment.insertSegment(withTitle: "신고 목록", at: 1, animated: true)
        segment.selectedSegmentIndex = 0
        let font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        segment.setTitleTextAttributes([NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: UIColor.picoFontGray], for: .normal)
        segment.setTitleTextAttributes([NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: UIColor.picoFontBlack], for: .selected)
        return segment
    }()
    
    private let underLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .picoFontBlack
        return view
    }()
    
    private let underLineBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .picoFontGray
        return view
    }()
    
    private let segmentView: UIView = {
        let view = UIView()
        view.configBackgroundColor()
        return view
    }()
    
    private let contentsView: UIView = UIView()
    
    private lazy var pageViewController: UIPageViewController = {
        let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageController.view.frame = contentsView.frame
        return pageController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tappedDismissKeyboard()
        addViews()
        makeConstraints()
        configNavigationBarButton()
        configTabBar()
    }
    
    private func configNavigationBarButton() {
        let setButton = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .done, target: self, action: #selector(tappedBarButton))
        setButton.tintColor = .darkGray
        setButton.accessibilityLabel = "설정"
        navigationItem.rightBarButtonItem = setButton
    }
    
    private func configTabBar() {
        tabSegmentedControl.addTarget(self, action: #selector(changeUnderLinePosition), for: .valueChanged)
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
    
    @objc private func tappedBarButton() {
        showCustomAlert(alertType: .canCancel, titleText: "나가기", messageText: "로그인화면으로 이동하시겠습니까 ?", confirmButtonText: "확인", comfrimAction: {
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootView(UINavigationController(rootViewController: SignViewController()), animated: true)
        })
    }
}

// MARK: - UI 관련
extension AdminViewController {
    
    private func addViews() {
        segmentView.addSubview([tabSegmentedControl, underLineBackgroundView, underLineView])
        contentsView.addSubview(pageViewController.view)
        
        view.addSubview([segmentView, contentsView])
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        segmentView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeArea)
            make.height.equalTo(50)
        }
        
        tabSegmentedControl.snp.makeConstraints { make in
            make.top.leading.centerX.centerY.equalTo(segmentView)
        }
        
        contentsView.snp.makeConstraints { make in
            make.top.equalTo(segmentView.snp.bottom)
            make.leading.trailing.equalTo(segmentView)
            make.bottom.equalToSuperview()
        }
        
        underLineBackgroundView.snp.makeConstraints { make in
            make.leading.bottom.equalTo(tabSegmentedControl)
            make.width.equalTo(tabSegmentedControl.snp.width)
            make.height.equalTo(0.5)
        }
        
        underLineView.snp.makeConstraints { make in
            make.leading.bottom.equalTo(tabSegmentedControl)
            make.width.equalTo(tabSegmentedControl.snp.width).multipliedBy(1 / CGFloat(tabSegmentedControl.numberOfSegments))
            make.height.equalTo(2)
        }
    }
}
