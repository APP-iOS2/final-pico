//
//  AdminUserViewController.swift
//  Pico
//
//  Created by 최하늘 on 10/4/23.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

final class AdminUserViewController: UIViewController {
    
    private lazy var sortedMenu: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "slider.horizontal.3"), for: .normal)
        button.tintColor = .picoFontGray
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    lazy var menu = UIMenu(title: "구분", children: [
        usingMenu, unsubscribedMenu, sortTypeMenu
    ])
    
    lazy var usingMenu = UIAction(title: "사용중인 회원", image: UIImage(), handler: { [weak self] _ in
        guard let self = self else { return }
        userListTypeBehavior.onNext(.using)
        scrollToTop()
    })
    
    lazy var unsubscribedMenu = UIAction(title: "탈퇴된 회원", image: UIImage(), handler: { [weak self] _ in
        guard let self = self else { return }
        userListTypeBehavior.onNext(.unsubscribe)
        scrollToTop()
    })
    
    lazy var sortTypeMenu = UIMenu(title: "정렬 구분", options: .displayInline, children: sortMenus)
    
    lazy var sortMenus = UserSortType.allCases.map { sortType in
        return UIAction(title: sortType.name, image: UIImage(), handler: { [weak self] _ in
            guard let self = self else { return }
            sortedTypeBehavior.onNext(sortType)
            scrollToTop()
        })
    }

    private let textFieldView: CommonTextField = CommonTextField()
    
    private let searchButton: UIButton = {
        let button = UIButton()
        button.setTitle("검색", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .picoButtonFont
        button.backgroundColor = .picoBlue
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let tableView = UITableView()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .picoBlue
        indicator.hidesWhenStopped = true
        indicator.isHidden = true
        return indicator
    }()
    
    private var viewModel: AdminUserViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let viewDidLoadPublisher = PublishSubject<Void>()
    private let viewWillAppearPublisher = PublishSubject<Void>()
    private let sortedTypeBehavior = BehaviorSubject(value: UserSortType.dateDescending)
    private let userListTypeBehavior = BehaviorSubject(value: UserListType.using)
    private let searchButtonPublisher = PublishSubject<String>()
    private let tableViewOffsetPublisher = PublishSubject<Void>()
    private let refreshablePublisher = PublishSubject<Void>()
    
    private let refreshControl = UIRefreshControl()
    
    init(viewModel: AdminUserViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        Loading.showLoading()
        addViews()
        makeConstraints()
        configRefresh()
        configButtons()
        configTableView()
        configTableViewDatasource()
        bind()
        viewDidLoadPublisher.onNext(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        viewWillAppearPublisher.onNext(())
    }
    
    private func configRefresh() {
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        refreshControl.tintColor = .picoBlue
    }
    
    private func configButtons() {
        searchButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { viewController, _ in
                viewController.searchButton.tappedAnimation()
                let text = viewController.textFieldView.textField.text
                viewController.searchButtonPublisher.onNext(text ?? "")
                viewController.scrollToTop()
            })
            .disposed(by: disposeBag)
    }
    
    private func configTableView() {
        tableView.showsVerticalScrollIndicator = false
        tableView.refreshControl = refreshControl
        tableView.register(cell: AdminUserTableViewCell.self)
        tableView.rowHeight = 80
        tableView.tableFooterView = activityIndicator
    }
    
    private func bind() {
        let input = AdminUserViewModel.Input(
            viewDidLoad: viewDidLoadPublisher.asObservable(),
            viewWillAppear: viewWillAppearPublisher.asObservable(),
            sortedType: sortedTypeBehavior.asObservable(),
            userListType: userListTypeBehavior.asObservable(),
            searchButton: searchButtonPublisher.asObservable(),
            tableViewOffset: tableViewOffsetPublisher.asObservable(),
            refreshable: refreshablePublisher.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output.resultTitleLabel
            .bind(to: textFieldView.textField.rx.placeholder)
            .disposed(by: disposeBag)

        let mergedData = Observable.merge(output.resultToViewDidLoad, output.resultSearchUserList, output.resultPagingList)
        
        mergedData
            .bind(to: tableView.rx.items(cellIdentifier: AdminUserTableViewCell.reuseIdentifier, cellType: AdminUserTableViewCell.self)) { _, item, cell in
                guard let imageURL = item.imageURLs[safe: 0] else { return }
                cell.configData(imageUrl: imageURL, nickName: item.nickName, age: item.age, mbti: item.mbti, createdDate: item.createdDate)
            }
            .disposed(by: disposeBag)
        
        output.needToReload
            .withUnretained(self)
            .subscribe(onNext: { viewController, _ in
                viewController.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    private func scrollToTop() {
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    @objc private func refreshTable(_ refresh: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            if let currentSortType = try? self.sortedTypeBehavior.value() {
                self.sortedTypeBehavior.onNext(currentSortType)
            }
            refreshablePublisher.onNext(())
            refresh.endRefreshing()
        }
    }
}

// MARK: - 테이블뷰관련
extension AdminUserViewController {
    
    private func configTableViewDatasource() {
        var isOffsetPublisherCalled = false

        tableView.rx.contentOffset
            .withUnretained(self)
            .subscribe(onNext: { viewController, contentOffset in
                let contentOffsetY = contentOffset.y
                let contentHeight = viewController.tableView.contentSize.height
                let boundsHeight = viewController.tableView.frame.size.height

                if contentOffsetY > contentHeight - boundsHeight && !viewController.activityIndicator.isAnimating {
                    if !isOffsetPublisherCalled {
                        viewController.activityIndicator.startAnimating()
                        viewController.tableViewOffsetPublisher.onNext(())
                        isOffsetPublisherCalled = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            viewController.activityIndicator.stopAnimating()
                        }
                    }
                } else {
                    isOffsetPublisherCalled = false
                }
            })
            .disposed(by: disposeBag)

        tableView.rx.itemSelected
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { viewController, indexPath in
                guard let user = viewController.viewModel.userList[safe: indexPath.row] else { return }
                let detailViewController = AdminUserDetailViewController(viewModel: AdminUserDetailViewModel(selectedUser: user))
                viewController.navigationController?.pushViewController(detailViewController, animated: true)
            })
            .disposed(by: disposeBag)            
    }
}

// MARK: - UI 관련
extension AdminUserViewController {
    
    private func addViews() {
        view.addSubview([textFieldView, searchButton, sortedMenu, tableView])
    }
    
    private func makeConstraints() {
        let padding: CGFloat = 10
        
        textFieldView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(padding)
            make.leading.equalTo(padding)
            make.height.equalTo(40)
        }
        
        searchButton.snp.makeConstraints { make in
            make.centerY.equalTo(textFieldView)
            make.leading.equalTo(textFieldView.snp.trailing).offset(padding)
            make.width.equalTo(60)
            make.height.equalTo(35)
        }
        
        sortedMenu.snp.makeConstraints { make in
            make.centerY.equalTo(textFieldView)
            make.leading.equalTo(searchButton.snp.trailing).offset(padding)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-padding)
            make.width.equalTo(textFieldView.snp.height)
            make.height.equalTo(textFieldView.snp.height)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(textFieldView.snp.bottom).offset(padding)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
