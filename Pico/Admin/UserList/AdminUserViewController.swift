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
    
    private lazy var filteredButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("이름", for: .normal)
        button.setTitleColor(.picoFontBlack, for: .normal)
        button.menu = UIMenu(title: "정렬", options: [.singleSelection], children: filteredMenuItems)
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    private lazy var filteredMenuItems: [UIAction] = {
        return FilterType.allCases.map { filterType in
            let title = filterType.name
            
            return UIAction(title: title, image: UIImage(), handler: { [weak self] _ in
                guard let self = self else { return }
                filteredButton.setTitle(title, for: .normal)
                filteredTypeBehavior.onNext(filterType)
            })
        }
    }()
    
    private let textField = CommonTextField()
    private let userListTableView = UITableView()
    
    // 질문: 이니셜라이저에서 받는건데 ! 써도 되는 지 ? (깃허브에는 !로 되어있어서요)
    private var viewModel: AdminUserViewModel!
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let viewDidLoadPublisher = PublishSubject<Void>()
    private let sortedTpyeBehavior = BehaviorSubject(value: SortType.dateDescending)
    private let filteredTypeBehavior = BehaviorSubject(value: FilterType.name)
    private let resultTextFieldPublisher = PublishSubject<String>()
    
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
        addViews()
        makeConstraints()
        configTableView()
        configTableViewDatasource()
        bind()
        viewDidLoadPublisher.onNext(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - config
    private func configTableView() {
        userListTableView.register(cell: NotificationTableViewCell.self)
        userListTableView.rowHeight = 80
    }
    
    private func bind() {
        let input = AdminUserViewModel.Input(
            viewDidLoad: viewDidLoadPublisher.asObservable(),
            sortedTpye: sortedTpyeBehavior.asObservable(),
            filteredType: filteredTypeBehavior.asObservable(),
            resultTextField: resultTextFieldPublisher.asObserver()
        )
        let output = viewModel.transform(input: input)

        output.resultToViewDidLoad
            .bind(to: userListTableView.rx.items(cellIdentifier: NotificationTableViewCell.reuseIdentifier, cellType: NotificationTableViewCell.self)) { _, item, cell in
                guard let imageURL = item.imageURLs[safe: 0] else { return }
                cell.configData(imageUrl: imageURL, nickName: item.nickName, age: item.age, mbti: item.mbti, createdDate: item.createdDate)
            }
            .disposed(by: disposeBag)

        textField.textInputPublisher.asObservable()
            .withUnretained(self)
            .subscribe(onNext: { viewController, text in
                viewController.resultTextFieldPublisher.onNext(text)
            })
            .disposed(by: disposeBag)
        
        output.needToReload
            .withUnretained(self)
            .subscribe(onNext: { viewController, _ in
                viewController.userListTableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - 테이블뷰관련
extension AdminUserViewController {
    
    private func configTableViewDatasource() {
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
        let views = [filteredButton, textField, sortedMenu, userListTableView]
        view.addSubview(views)
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
            make.trailing.equalTo(sortedMenu.snp.leading).offset(-padding)
            make.height.equalTo(filteredButton.snp.height)
        }
        
        sortedMenu.snp.makeConstraints { make in
            make.top.equalTo(filteredButton)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-padding)
            make.width.equalTo(filteredButton.snp.height)
            make.height.equalTo(filteredButton.snp.height)
        }
        
        userListTableView.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(padding)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
