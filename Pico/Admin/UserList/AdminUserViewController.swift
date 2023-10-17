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
        button.menu = UIMenu(title: "정렬", options: [.singleSelection], children: sortedMenuItems)
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    private lazy var sortedMenuItems: [UIAction] = {
        return SortType.allCases.map { sortType in
            let title = sortType.name
            
            return UIAction(title: title, image: UIImage(), handler: { [weak self] _ in
                guard let self = self else { return }
                sortedTpyeBehavior.onNext(sortType)
            })
        }
    }()
    
    private let textFieldView: CommonTextField = {
        let textField = CommonTextField()
        textField.textField.placeholder = "이름을 검색하세요."
        return textField
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton()
        button.setTitle("검색", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .picoButtonFont
        button.backgroundColor = .picoBlue
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let userListTableView = UITableView()
    
    // 질문: 이니셜라이저에서 받는건데 ! 써도 되는 지 ? (깃허브에는 !로 되어있어서요)
    private var viewModel: AdminUserViewModel!
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let viewDidLoadPublisher = PublishSubject<Void>()
    private let sortedTpyeBehavior = BehaviorSubject(value: SortType.dateDescending)
    private let searchButtonPublisher = PublishSubject<String>()
    private let tableViewOffsetPublisher = PublishSubject<Void>()
    private let refreshablePublisher = PublishSubject<Void>()
    
    private let refreshControl = UIRefreshControl()
    
    init(viewModel: AdminUserViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
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
    }
    
    private func configRefresh() {
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        refreshControl.tintColor = .picoBlue
        userListTableView.refreshControl = refreshControl
    }
    
    private func configButtons() {
        searchButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { viewController, _ in
                viewController.searchButton.tappedAnimation()
                let text = viewController.textFieldView.textField.text
                viewController.searchButtonPublisher.onNext(text ?? "")
            })
            .disposed(by: disposeBag)
    }
    
    private func configTableView() {
        userListTableView.register(cell: NotificationTableViewCell.self)
        userListTableView.rowHeight = 180
    }
    
    private func bind() {
        let input = AdminUserViewModel.Input(
            viewDidLoad: viewDidLoadPublisher.asObservable(),
            sortedTpye: sortedTpyeBehavior.asObservable(),
            searchButton: searchButtonPublisher.asObservable(),
            tableViewOffset: tableViewOffsetPublisher.asObservable(),
            refreshable: refreshablePublisher.asObservable()
        )
        let output = viewModel.transform(input: input)

        let combinedData = Observable.merge(output.resultToViewDidLoad, output.resultSearchUserList, output.resultPagingList)
        
        combinedData
            .bind(to: userListTableView.rx.items(cellIdentifier: NotificationTableViewCell.reuseIdentifier, cellType: NotificationTableViewCell.self)) { _, item, cell in
                guard let imageURL = item.imageURLs[safe: 0] else { return }
                cell.configData(imageUrl: imageURL, nickName: item.nickName, age: item.age, mbti: item.mbti, createdDate: item.createdDate)
            }
            .disposed(by: disposeBag)
        
        output.needToReload
            .withUnretained(self)
            .subscribe(onNext: { viewController, _ in
                viewController.userListTableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func refreshTable(_ refresh: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            if let currentSortType = try? self.sortedTpyeBehavior.value() {
                self.sortedTpyeBehavior.onNext(currentSortType)
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
        
        userListTableView.rx.contentOffset
            .withUnretained(self)
            .subscribe(onNext: { viewController, contentOffset in
                let contentOffsetY = contentOffset.y
                let contentHeight = viewController.userListTableView.contentSize.height
                let boundsHeight = viewController.userListTableView.frame.size.height

                if contentOffsetY > contentHeight - boundsHeight {
                    if !isOffsetPublisherCalled {
                        viewController.tableViewOffsetPublisher.onNext(())
                        isOffsetPublisherCalled = true
                    }
                } else {
                    isOffsetPublisherCalled = false
                }
            })
            .disposed(by: disposeBag)

        userListTableView.rx.modelSelected(User.self)
            .subscribe { [weak self] user in
                let viewController = AdminUserDetailViewController(viewModel: AdminUserDetailViewModel(selectedUser: user))
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UI 관련
extension AdminUserViewController {
    
    private func addViews() {
        let views = [textFieldView, searchButton, sortedMenu, userListTableView]
        view.addSubview(views)
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
        
        userListTableView.snp.makeConstraints { make in
            make.top.equalTo(textFieldView.snp.bottom).offset(padding)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
