//
//  AdminViewController.swift
//  Pico
//
//  Created by 최하늘 on 10/4/23.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

final class AdminViewController: BaseViewController {
    
    private lazy var sortedMenu: UIMenu = {
        return UIMenu(title: "정렬", options: [.singleSelection], children: sortedMenuItems)
    }()
    
    private lazy var sortedMenuItems: [UIAction] = {
        return SortType.allCases.map { sortType in
            let title = sortType.name
            
            return UIAction(title: title, image: UIImage(), handler: { [weak self] _ in
                guard let self = self else { return }
                viewModel.updateSelectedSortType(to: sortType)
            })
        }
    }()
    
    private lazy var filteredButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("이름", for: .normal)
        button.menu = UIMenu(title: "정렬", options: [.singleSelection], children: filteredMenuItems)
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    private lazy var filteredMenuItems: [UIAction] = {
        return FilterType.allCases.map { filterType in
            let title = filterType.name
            
            return UIAction(title: title, image: UIImage(), handler: { [weak self] _ in
                guard let self = self else { return }
                viewModel.updateSelectedFilterType(to: filterType)
            })
        }
    }()
    
    private let textField = CommonTextField()
    private let userListTableView = UITableView()
    
    private let disposeBag: DisposeBag = DisposeBag()
    private let viewModel: AdminViewModel = AdminViewModel()

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tappedDismissKeyboard()
        addViews()
        makeConstraints()
        configNavigationBarItem()
        configTableView()
        configTableViewDatasource()
    }
    
    // MARK: - config
    private func configNavigationBarItem() {
        let filterButton = UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3"), menu: sortedMenu)
        filterButton.tintColor = .darkGray
        self.navigationItem.rightBarButtonItem = filterButton
    }
    
    private func configTableView() {
        userListTableView.register(cell: NotificationTableViewCell.self)
        userListTableView.rowHeight = 80
    }
}

// MARK: - 테이블뷰관련
extension AdminViewController {
    
    private func configTableViewDatasource() {
        viewModel.filteredUsers
            .bind(to: userListTableView.rx.items(cellIdentifier: NotificationTableViewCell.reuseIdentifier, cellType: NotificationTableViewCell.self)) { _, item, cell in
                guard let imageURL = item.imageURLs[safe: 0] else { return }
                cell.configData(imageUrl: imageURL, nickName: item.nickName, age: item.age, mbti: item.mbti, createdDate: item.createdDate.toString())
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UI 관련
extension AdminViewController {
    
    private func addViews() {
        view.addSubview(filteredButton)
        view.addSubview(textField)
        view.addSubview(userListTableView)
    }
    
    private func makeConstraints() {
        let padding: CGFloat = 10
        
        filteredButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(padding)
            make.leading.equalTo(padding)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(filteredButton)
            make.leading.equalTo(filteredButton.snp.trailing).offset(padding)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-padding)
            make.height.equalTo(filteredButton.snp.height)
        }
        
        userListTableView.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(padding)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
