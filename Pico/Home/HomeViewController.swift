//
//  ViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class HomeViewController: BaseViewController {
    
    var removedView: [UIView] = []
    var filterGender: [GenderType] = HomeFilterViewController.filterGender
    lazy var likeLabel: UILabel = createLabel(text: "GOOD", setColor: .systemGreen)
    lazy var passLabel: UILabel = createLabel(text: "PASS", setColor: .systemBlue)
    
    private let numberOfCards: Int = 7
    private let emptyView: HomeEmptyView = HomeEmptyView()
    private let tempUser = BehaviorRelay<[User]>(value: [])
    private let disposeBag = DisposeBag()
    private let viewModel = HomeViewModel()
    
    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubView()
        makeConstraints()
        configNavigationBarItem()
        configButtons()
        
        viewModel.users
            .bind(to: tempUser)
            .disposed(by: disposeBag)
    }
    
    private func addSubView() {
        tempUser
            .map { users in
                return users.filter { user in
                    return self.filterGender.contains(user.gender)
                }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] filteredUsers in
                guard let self = self else { return }
                var shuffledUsers = filteredUsers.shuffled()
                for (index, user) in shuffledUsers.enumerated() where index <= numberOfCards - 1 {
                        let tabImageViewController = HomeUserCardViewController(user: user)
                        tabImageViewController.homeViewController = self
                        self.addChild(tabImageViewController)
                        self.view.insertSubview(tabImageViewController.view, at: 1)
                }
                self.view.insertSubview(emptyView, at: 0)
            })
            .disposed(by: disposeBag)
        view.addSubview(likeLabel)
        view.addSubview(passLabel)
    }
    
    private func makeConstraints() {
        emptyView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        likeLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.safeAreaLayoutGuide.snp.top).offset(70)
            make.width.equalTo(150)
        }
        
        passLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.safeAreaLayoutGuide.snp.top).offset(70)
            make.width.equalTo(150)
        }
    }
    
    private func configButtons() {
        emptyView.reLoadButton.addTarget(self, action: #selector(reloadView), for: .touchUpInside)
    }
    
    private func configNavigationBarItem() {
        let filterImage = UIImage(systemName: "slider.horizontal.3")
        let filterButton = UIBarButtonItem(image: filterImage, style: .plain, target: self, action: #selector(tappedFilterButton))
        filterButton.tintColor = .darkGray
        
        let notificationImage = UIImage(systemName: "bell.fill")
        let notificationButton = UIBarButtonItem(image: notificationImage, style: .plain, target: self, action: #selector(tappedNotificationButton))
        notificationButton.tintColor = .darkGray
        
        navigationItem.rightBarButtonItems = [filterButton, notificationButton]
    }
    
    private func createLabel(text: String, setColor: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 40)
        label.textColor = setColor.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.layer.borderWidth = 4
        label.layer.borderColor = setColor.withAlphaComponent(0.8).cgColor
        label.layer.cornerRadius = 5
        label.alpha = 0
        return label
    }
    
    @objc func reloadView() {
        let newViewController = HomeViewController()
        self.navigationController?.setViewControllers([newViewController], animated: false)
        HomeUserCardViewModel.passedMyData.removeAll()
        HomeUserCardViewModel.passedUserData.removeAll()
    }

    @objc func tappedFilterButton() {
        let viewController = HomeFilterViewController()
        viewController.homeViewController = self
        addChild(viewController)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func tappedNotificationButton() {
        let viewController = NotificationViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}
