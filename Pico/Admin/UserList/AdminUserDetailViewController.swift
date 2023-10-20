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
    
    private let unsubscribeButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let backImage = UIImage(systemName: "ellipsis", withConfiguration: imageConfig)
        let button = UIButton(type: .system)
        button.setImage(backImage, for: .normal)
        button.tintColor = .picoBlue
        return button
    }()
    
    private let tableView: UITableView = UITableView()
    
    private var viewModel: AdminUserDetailViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let recordTypePublish = PublishSubject<RecordType>()
    private let refreshablePublish = PublishSubject<RecordType>()
    private let unsubscribePublish = PublishSubject<Void>()
    
    private var currentRecordType: RecordType = .report
    private let footerView = FooterView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
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
        activityIndicator.tintColor = .picoBlue
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isHidden = true
        tableView.tableFooterView = activityIndicator
    }
    
    private func configTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cell: DetailUserImageTableViewCell.self)
        tableView.register(cell: DetailUserInfoTableViewCell.self)
        tableView.register(cell: RecordHeaderTableViewCell.self)
        tableView.register(cell: NotificationTableViewCell.self)
        tableView.separatorStyle = .none
        
        footerView.frame = CGRect(x: 0,
                                  y: 0,
                                  width: tableView.bounds.size.width,
                                  height: 80)
    }
    
    private func configButtons() {
        backButton.addTarget(self, action: #selector(tappedBackButton), for: .touchUpInside)
        unsubscribeButton.addTarget(self, action: #selector(tappedUnsubscribeButton), for: .touchUpInside)
    }
    
    private func bind() {
        let input = AdminUserDetailViewModel.Input(
            selectedRecordType: recordTypePublish.asObservable(),
            refreshable: refreshablePublish.asObservable(),
            isUnsubscribe: unsubscribePublish.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        let merged = Observable.merge(output.needToFirstLoad, output.needToRefresh)
        
        merged
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { viewController, recordType in
                viewController.currentRecordType = recordType
                viewController.reloadRecord()
            })
            .disposed(by: disposeBag)
        
        //        output.needToFirstLoad
        //            .withUnretained(self)
        //            .observe(on: MainScheduler.instance)
        //            .subscribe { viewController, recordType in
        //                viewController.currentRecordType = recordType
        //                viewController.reloadRecord()
        //            }
        //            .disposed(by: disposeBag)
        //
        //        output.needToRefresh
        //            .withUnretained(self)
        //            .observe(on: MainScheduler.instance)
        //            .subscribe { viewController, _ in
        //                viewController.reloadRecord()
        //            }
        //            .disposed(by: disposeBag)
        
        output.resultIsUnsubscribe
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { viewController, _ in
                viewController.showCustomAlert(alertType: .onlyConfirm, titleText: "알림", messageText: "탈퇴가 완료되었습니다.", confirmButtonText: "확인", comfrimAction: {
                    viewController.navigationController?.popViewController(animated: true)
                })
            })
            .disposed(by: disposeBag)
        
        output.needToReload
            .withUnretained(self)
            .subscribe(onNext: { viewController, _ in
                viewController.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    private func reloadRecord() {
        tableView.reloadSections(IndexSet(3...3), with: .automatic)
        activityIndicator.stopAnimating()
    }
    
    @objc private func tappedBackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func tappedUnsubscribeButton(_ sender: UIButton) {
        let actionSheetController = UIAlertController()
        let actionUnsubscribe = UIAlertAction(title: "탈퇴", style: .destructive) { [weak self] _ in
            guard let self else { return }
            showCustomAlert(alertType: .canCancel, titleText: "탈퇴", messageText: "탈퇴하시겠습니까 ?", confirmButtonText: "탈퇴", comfrimAction: { [weak self] in
                guard let self else { return }
                unsubscribePublish.onNext(())
            })
        }
        let actionCancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        [actionUnsubscribe, actionCancel].forEach {
            actionSheetController.addAction($0)
        }
        self.present(actionSheetController, animated: true)
    }
}

extension AdminUserDetailViewController: UITableViewDelegate, UITableViewDataSource {
    enum TableViewCase: CaseIterable {
        case image, info
        case recordHeader
        case record
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tableViewCase = TableViewCase.allCases[safe: section] else { return 0 }
        
        switch tableViewCase {
        case .image, .info, .recordHeader:
            return 1
        case .record:
            switch currentRecordType {
            case .report:
                return 0
            case .block:
                return 0
            case .like:
                return viewModel.likeList.count
            case .payment:
                return 0
            }
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
                .subscribe(onNext: { viewController, recordType in
                    print(recordType)
                    viewController.recordTypePublish.onNext(recordType)
                })
                .disposed(by: disposeBag)
            return cell
            
        case .record:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: NotificationTableViewCell.self)
            
            switch currentRecordType {
            case .report:
                break
                
            case .block:
                break
                
            case .like:
                guard let user = viewModel.likeList[safe: indexPath.row] else { return UITableViewCell() }
                cell.configData(notitype: .like, imageUrl: user.imageURL, nickName: user.nickName, age: user.age, mbti: user.mbti, date: Date().timeIntervalSince1970)
                
            case .payment:
                break
            }
            
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
            return 70
        case .record:
            return 80
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let maxAlpha = 0.8
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
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offset = scrollView.contentOffset.y
        let contentHeight = tableView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        let size = contentHeight - scrollViewHeight
        if offset > size && !activityIndicator.isAnimating {
            activityIndicator.startAnimating()
            refreshablePublish.onNext(currentRecordType)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard let self else { return }
                activityIndicator.stopAnimating()
            }
        }
    }
}

extension AdminUserDetailViewController {
    private func addViews() {
        view.addSubview([tableView, topView])
        topView.addSubview([backButton, unsubscribeButton])
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
            make.width.height.equalTo(topView.snp.height)
        }
        
        unsubscribeButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.width.height.equalTo(backButton.snp.height)
        }
    }
}
