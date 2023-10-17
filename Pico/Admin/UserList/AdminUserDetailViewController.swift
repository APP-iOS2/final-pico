//
//  AdminUserDetailViewController.swift
//  Pico
//
//  Created by 최하늘 on 10/12/23.
//

import UIKit
import SnapKit
import RxSwift

struct UserImage {
    static let height: CGFloat = Screen.height * 0.6
}

final class AdminUserDetailViewController: UIViewController {
  
    private let topView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let backButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let backImage = UIImage(systemName: "chevron.left", withConfiguration: imageConfig)
        let button = UIButton(type: .system)
        button.setImage(backImage, for: .normal)
        button.tintColor = .picoBlue
        return button
    }()
    
    private let tableView: UITableView = UITableView()
    
    private var viewModel: AdminUserDetailViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let recordTypePublish = PublishSubject<RecordType>()
    
    init(viewModel: AdminUserDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.configBackgroundColor()
        addViews()
        makeConstraints()
        configTableView()
        configButtons()
        bind()
    }
    
    private func configTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cell: DetailUserImageTableViewCell.self)
        tableView.register(cell: DetailUserInfoTableViewCell.self)
        tableView.register(cell: RecordHeaderTableViewCell.self)
        tableView.register(cell: NotificationTableViewCell.self)
        tableView.separatorStyle = .none
    }
    
    private func configButtons() {
        backButton.addTarget(self, action: #selector(tappedBackButton), for: .touchUpInside)
    }
    
    private func bind() {
        let input = AdminUserDetailViewModel.Input(
            selectedRecordType: recordTypePublish.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output.needToReload
            .withUnretained(self)
            .subscribe(onNext: { viewController, _ in
                viewController.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func tappedBackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension AdminUserDetailViewController: UITableViewDelegate, UITableViewDataSource {
    enum TableViewCase: CaseIterable {
        case image
        case info
        case recordHeader
        case record
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tableViewCase = TableViewCase.allCases[safe: section] else { return 0 }
        
        switch tableViewCase {
        case .image, .info, .recordHeader:
            return 1
        case .record:
            return viewModel.recordList.count
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return TableViewCase.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tableViewCase = TableViewCase.allCases[safe: indexPath.section] else { return UITableViewCell()}

        switch tableViewCase {
        case .image:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: DetailUserImageTableViewCell.self)
            cell.config(images: viewModel.selectedUser.imageURLs)
            cell.selectionStyle = .none
            return cell

        case .info:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: DetailUserInfoTableViewCell.self)
            cell.config(user: viewModel.selectedUser)
            cell.selectionStyle = .none
            return cell
            
        case .recordHeader:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: RecordHeaderTableViewCell.self)
            cell.selectionStyle = .none
            cell.selectedRecordTypePublisher.asObservable()
                .withUnretained(self)
                .subscribe(onNext: {  viewController, recordType in
                    viewController.recordTypePublish.onNext(recordType)
                })
                .disposed(by: disposeBag)
            return cell
            
        case .record:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: NotificationTableViewCell.self)
            
            guard let user = viewModel.recordList[safe: indexPath.row] else { return UITableViewCell() }
            cell.configData(notitype: .like, imageUrl: user.imageURL, nickName: user.nickName, age: user.age, mbti: user.mbti, date: Date().timeIntervalSince1970)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let tableViewCase = TableViewCase.allCases[safe: indexPath.section] else { return 0 }
        
        switch tableViewCase {
        case .image:
            return UserImage.height
        case .info:
            return UITableView.automaticDimension
        case .recordHeader:
            return 50
        case .record:
            return 100
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let maxAlpha = 0.7
        let maxHeight = UserImage.height
        
        switch offset {
        case ...0:
            topView.backgroundColor = .clear
        case 1...maxHeight:
            let alpha = offset * maxAlpha / maxHeight
            topView.backgroundColor = .systemBackground.withAlphaComponent(alpha)
        default:
            topView.backgroundColor = .systemBackground.withAlphaComponent(maxAlpha)
        }
    }
}

extension AdminUserDetailViewController {
    private func addViews() {
        view.addSubview([tableView, topView])
        topView.addSubview(backButton)
    }
    
    private func makeConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        topView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        backButton.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.width.equalTo(topView.snp.height)
            make.height.equalTo(topView.snp.height)
        }
    }
}
