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
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .picoBlue
        indicator.hidesWhenStopped = true
        indicator.isHidden = true
        return indicator
    }()

    private var viewModel: AdminUserDetailViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let viewDidLoadPublish = PublishSubject<Void>()
    private let selectedRecordTypePublish = PublishSubject<RecordType>()
    private let refreshablePublish = PublishSubject<RecordType>()
    private let unsubscribePublish = PublishSubject<Void>()
    private let cellRecordTypePublish = PublishSubject<RecordType>()
    
    private var currentRecordType: RecordType = .report {
        didSet {
            reloadRecordSection()
        }
    }
    
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
        viewDidLoadPublish.onNext(())
    }
    
    private func configTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cell: DetailUserImageTableViewCell.self)
        tableView.register(cell: DetailUserInfoTableViewCell.self)
        tableView.register(cell: RecordHeaderTableViewCell.self)
        tableView.register(cell: AdminUserTableViewCell.self)
        tableView.register(cell: RecordEmptyTableViewCell.self)
        tableView.separatorStyle = .none
        tableView.tableFooterView = activityIndicator
    }
    
    private func configButtons() {
        backButton.addTarget(self, action: #selector(tappedBackButton), for: .touchUpInside)
        unsubscribeButton.addTarget(self, action: #selector(tappedUnsubscribeButton), for: .touchUpInside)
    }
    
    private func bind() {
        let input = AdminUserDetailViewModel.Input(
            viewDidLoad: viewDidLoadPublish.asObservable(),
            selectedRecordType: selectedRecordTypePublish.asObservable(),
            refreshable: refreshablePublish.asObservable(),
            isUnsubscribe: unsubscribePublish.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output.needToFirstLoad
            .withUnretained(self)
            .subscribe { viewController, _ in
                print("viewController.viewModel.reportList \(viewController.viewModel.reportList.count)")
                print("viewController.viewModel.likeList \(viewController.viewModel.likeList.count)")
            }
            .disposed(by: disposeBag)
        
        output.resultRecordType
            .withUnretained(self)
            .subscribe { viewController, recordType in
                print("선택한 레코드타입 도착, \(recordType)")
                viewController.currentRecordType = recordType
                viewController.scrollToRow()
            }
            .disposed(by: disposeBag)
        
        output.needToRefresh
            .withUnretained(self)
            .subscribe { viewController, _ in
                print("viewController 리프레시 도착, 신고 \(viewController.viewModel.reportList.count), 좋아요 \(viewController.viewModel.likeList.count)")
            }
            .disposed(by: disposeBag)
        
        output.resultIsUnsubscribe
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { viewController, _ in
                viewController.showCustomAlert(alertType: .onlyConfirm, titleText: "알림", messageText: "탈퇴가 완료되었습니다.", confirmButtonText: "확인", comfrimAction: {
                    viewController.navigationController?.popViewController(animated: true)
                })
            })
            .disposed(by: disposeBag)
        
        output.needToRecordReload
            .withUnretained(self)
            .subscribe(onNext: { viewController, _ in
                viewController.reloadRecordSection()
            })
            .disposed(by: disposeBag)
        
        cellRecordTypePublish
            .withUnretained(self)
            .subscribe(onNext: { viewController, recordType in
                viewController.selectedRecordTypePublish.onNext(recordType)
            })
            .disposed(by: disposeBag)
    }
    
    private func reloadRecordSection() {
        print("리로리로리로리드")
        let emptyIndex: Int = TableViewCase.empty.rawValue
        let recordIndex: Int = TableViewCase.record.rawValue
        tableView.reloadSections(IndexSet(emptyIndex...recordIndex), with: .automatic)
        activityIndicator.stopAnimating()
    }
    
    private func scrollToRow() {
        let indexPath = IndexPath(row: 0, section: 1)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    @objc private func tappedBackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func tappedUnsubscribeButton(_ sender: UIButton) {
        showCustomAlert(
            alertType: .canCancel,
            titleText: "탈퇴 알림",
            messageText: "탈퇴시키시겠습니까 ?",
            confirmButtonText: "탈퇴",
            comfrimAction: { [weak self] in
                guard let self else { return }
                unsubscribePublish.onNext(())
            })
    }
}

extension AdminUserDetailViewController: UITableViewDelegate, UITableViewDataSource {
    enum TableViewCase: Int, CaseIterable {
        case image, info
        case recordHeader
        case empty
        case record
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tableViewCase = TableViewCase.allCases[safe: section] else { return 0 }
        
        switch tableViewCase {
        case .image, .info, .recordHeader:
            return 1
        case .empty:
            return viewModel.isEmpty ? 1 : 0
        case .record:
            switch currentRecordType {
            case .report:
                return viewModel.reportList.count
            case .block:
                return viewModel.blockList.count
            case .like:
                return viewModel.likeList.count
            case .payment:
                return viewModel.paymentList.count
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TableViewCase.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tableViewCase = TableViewCase.allCases[safe: indexPath.section] else { return UITableViewCell()}
        
        switch tableViewCase {
        // MARK: - image
        case .image:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: DetailUserImageTableViewCell.self)
            cell.config(images: viewModel.selectedUser.imageURLs)
            cell.selectionStyle = .none
            return cell
            
        // MARK: - info
        case .info:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: DetailUserInfoTableViewCell.self)
            cell.config(user: viewModel.selectedUser)
            cell.selectionStyle = .none
            return cell
            
        // MARK: - recordHeader
        case .recordHeader:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: RecordHeaderTableViewCell.self)
            cell.config(publisher: cellRecordTypePublish)
            cell.selectionStyle = .none
            return cell
            
        // MARK: - empty
        case .empty:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: RecordEmptyTableViewCell.self)
            cell.selectionStyle = .none
            return cell
            
        // MARK: - record
        case .record:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: AdminUserTableViewCell.self)
            
            switch currentRecordType {
            // 신고기록
            case .report:
                guard let user = viewModel.reportList[safe: indexPath.row] else { return UITableViewCell() }
                cell.configData(recordType: .report, imageUrl: user.imageURL, nickName: user.nickName, age: user.age, mbti: user.mbti, createdDate: user.createdDate, reportReason: user.reason)
            
            // 차단기록
            case .block:
                guard let user = viewModel.blockList[safe: indexPath.row] else { return UITableViewCell() }
                cell.configData(recordType: .block, imageUrl: user.imageURL, nickName: user.nickName, age: user.age, mbti: user.mbti, createdDate: user.createdDate)
                
            // 좋아요기록
            case .like:
                guard let user = viewModel.likeList[safe: indexPath.row] else { return UITableViewCell() }
                cell.configData(recordType: .like, imageUrl: user.imageURL, nickName: user.nickName, age: user.age, mbti: user.mbti, createdDate: user.createdDate)
            
            // 결제기록
            case .payment:
                guard let payment = viewModel.paymentList[safe: indexPath.row] else { return UITableViewCell() }
                cell.configData(recordType: .payment, payment: payment)
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
        case .empty:
            return UITableView.automaticDimension
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
