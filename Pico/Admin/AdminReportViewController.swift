//
//  AdminReportViewController.swift
//  Pico
//
//  Created by 최하늘 on 10/11/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class AdminReportViewController: UIViewController {
    
    private lazy var sortedMenu: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "slider.horizontal.3"), for: .normal)
        button.tintColor = .picoFontGray
        button.menu = sortTypeMenu
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    lazy var sortTypeMenu = UIMenu(title: "정렬 구분", options: .displayInline, children: sortMenus)
    
    lazy var sortMenus = ReportSortType.allCases.map { sortType in
        return UIAction(title: sortType.name, image: UIImage(), handler: { [weak self] _ in
            guard let self = self else { return }
            viewDidLoadPublisher.onNext(sortType)
            scrollToTop()
        })
    }

    private let textFieldView: CommonTextField = {
        let textfield = CommonTextField()
        textfield.textField.placeholder = "\"신고자\"의 이름을 검색하세요."
        return textfield
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
    
    private let tableView = UITableView()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .picoBlue
        indicator.hidesWhenStopped = true
        indicator.isHidden = true
        return indicator
    }()
    
    private var viewModel: AdminReportViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let viewDidLoadPublisher = PublishSubject<ReportSortType>()
    private let searchButtonPublisher = PublishSubject<String>()
    private let tableViewOffsetPublisher = PublishSubject<Void>()
    private let reportedUserIdPublisher = PublishSubject<String>()
    
    private let refreshControl = UIRefreshControl()
    
    init(viewModel: AdminReportViewModel) {
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
        viewDidLoadPublisher.onNext(ReportSortType.dateDescending)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    private func configRefresh() {
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        refreshControl.tintColor = .picoBlue
    }
    
    private func configButtons() {
        searchButton.rx.tap
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { viewController, _ in
                viewController.searchButton.tappedAnimation()
                let text = viewController.textFieldView.textField.text
                viewController.searchButtonPublisher.onNext(text ?? "")
                viewController.scrollToTop()
            })
            .disposed(by: disposeBag)
    }
    
    private func configTableView() {
        tableView.refreshControl = refreshControl
        tableView.tableFooterView = activityIndicator
        tableView.register(cell: AdminUserTableViewCell.self)
        tableView.rowHeight = 80
        tableView.showsVerticalScrollIndicator = false
    }
    
    private func scrollToTop() {
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }

    @objc private func refreshTable(_ refresh: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            viewDidLoadPublisher.onNext(viewModel.selectedSortType)
            refresh.endRefreshing()
        }
    }
    
    private func bind() {
        let input = AdminReportViewModel.Input(
            viewDidLoad: viewDidLoadPublisher.asObservable(),
            searchButton: searchButtonPublisher.asObservable(),
            tableViewOffset: tableViewOffsetPublisher.asObservable(),
            reportedUserId: reportedUserIdPublisher.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        let mergedData = Observable.merge(output.resultToViewDidLoad, output.resultSearchUserList, output.resultPagingList)
        
        mergedData
            .bind(to: tableView.rx.items(cellIdentifier: AdminUserTableViewCell.reuseIdentifier, cellType: AdminUserTableViewCell.self)) { _, report, cell in
                cell.configData(recordType: .report, report: report)
            }
            .disposed(by: disposeBag)
        
        output.resultReportedUser
            .withUnretained(self)
            .subscribe(onNext: { viewController, user in
                guard let user else { return }
                viewController.pushAdminUserDetial(user)
            })
            .disposed(by: disposeBag)
    }
}

extension AdminReportViewController {
    
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

        tableView.rx.modelSelected(AdminReport.self)
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe { viewController, report in
                viewController.reportedUserIdPublisher.onNext(report.reportedUserId)
            }
            .disposed(by: disposeBag)
    }
    
    private func pushAdminUserDetial(_ user: User) {
        let viewController = AdminUserDetailViewController(viewModel: AdminUserDetailViewModel(selectedUser: user))
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension AdminReportViewController {
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
