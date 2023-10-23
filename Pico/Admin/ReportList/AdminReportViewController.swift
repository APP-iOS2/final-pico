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
    
    private var viewModel: AdminReportViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let viewDidLoadPublisher = PublishSubject<ReportSortType>()
    
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
            .subscribe(onNext: { viewController, _ in
                viewController.searchButton.tappedAnimation()
//                let text = viewController.textFieldView.textField.text
//                viewController.searchButtonPublisher.onNext(text ?? "")
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
//            if let currentSortType = try? self.sortedTypeBehavior.value() {
//                self.sortedTypeBehavior.onNext(currentSortType)
//            }
//            refreshablePublisher.onNext(())
            refresh.endRefreshing()
        }
    }
    
    private func bind() {
        let input = AdminReportViewModel.Input(
            viewDidLoad: viewDidLoadPublisher.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.resultToViewDidLoad
            .bind(to: tableView.rx.items(cellIdentifier: AdminUserTableViewCell.reuseIdentifier, cellType: AdminUserTableViewCell.self)) { _, report, cell in
                cell.configData(recordType: .report, report: report)
            }
            .disposed(by: disposeBag)
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
