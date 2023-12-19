//
//  ChattingTableListController.swift
//  Pico
//
//  Created by 양성혜 on 2023/12/16.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ChattingTableListController: BaseViewController {
    
    private let viewModel = ChattingViewModel()
    private let disposeBag = DisposeBag()
    private let emptyView: EmptyViewController = EmptyViewController(type: .message)
    private let refreshControl = UIRefreshControl()
    private let refreshPublisher = PublishSubject<Void>()
    private let loadDataPublsher = PublishSubject<Void>()
    private let checkChattingEmptyPublisher = PublishSubject<Void>()
    private let deleteChattingPublisher = PublishSubject<String>()
    private let footerView = FooterView()
    private var isRefresh = false
    
    private let chattingLabel: UILabel = {
        let label = UILabel()
        label.text = "채팅"
        label.font = UIFont.picoLargeTitleFont
        return label
    }()
    
    private let chattingListTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(cell: MailListTableViewCell.self)
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        return tableView
    }()
    
    
    // MARK: - MailView +LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configRefresh()
        configTableView()
        loadDataPublsher.onNext(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.startIndex = 0
        refreshPublisher.onNext(())
        checkChattingEmptyPublisher.onNext(())
        chattingListTableView.reloadData()
    }
    // MARK: - config
    
    private func configTableView() {
        footerView.frame = CGRect(x: 0, y: 0, width: chattingListTableView.bounds.size.width, height: 80)
        chattingListTableView.dataSource = self
        chattingListTableView.delegate = self
    }
    
    private func configRefresh() {
        refreshControl.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        refreshControl.tintColor = .picoBlue
        chattingListTableView.refreshControl = refreshControl
    }
    // MARK: - objc
    @objc private func refreshTable(refresh: UIRefreshControl) {
        isRefresh = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            viewModel.startIndex = 0
            refreshPublisher.onNext(())
            refresh.endRefreshing()
            isRefresh = false
        }
    }
}
// MARK: - UIMailTableView
extension ChattingTableListController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("갯수 :  \(viewModel.roomList.count)")
        return viewModel.roomList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: ChattingListTableViewCell.self)
        guard let item = viewModel.roomList[safe: indexPath.row] else { return UITableViewCell() }
        cell.config(receiveUser: item)
        print("item: \(item)")
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chattingDetailView = ChattingDetailViewController()
        chattingDetailView.modalPresentationStyle = .fullScreen
        //chattingDetailView.opponentUid = viewModel.chattingList.roomID
       
        self.present(chattingDetailView, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
// MARK: - bind
extension ChattingTableListController {
    private func bind() {
        let input = ChattingViewModel.Input(
            listLoad: loadDataPublsher,
            refresh: refreshPublisher,
            isChattingEmptyChecked: checkChattingEmptyPublisher)
        let output = viewModel.transform(input: input)
        
        let safeArea = view.safeAreaLayoutGuide
        
        output.chattingIsEmpty
            .withUnretained(self)
            .subscribe(onNext: { viewController, isEmpty in
                
                if isEmpty {
                    viewController.addChild(viewController.emptyView)
                    viewController.view.addSubview([self.chattingLabel, viewController.emptyView.view ?? UIView()])
                    viewController.chattingLabel.snp.makeConstraints { make in
                        make.top.equalTo(safeArea)
                        make.trailing.leading.equalTo(safeArea).offset(20)
                        make.height.equalTo(50)
                    }
                    viewController.emptyView.didMove(toParent: self)
                    viewController.emptyView.view.snp.makeConstraints { make in
                        make.top.equalTo(self.chattingLabel.snp.bottom).offset(20)
                        make.leading.trailing.bottom.equalToSuperview()
                    }
                } else {
                    viewController.view.addSubview([self.chattingLabel, viewController.chattingListTableView])
                    viewController.chattingLabel.snp.makeConstraints { make in
                        make.top.equalTo(safeArea)
                        make.trailing.leading.equalTo(safeArea).offset(20)
                        make.height.equalTo(50)
                    }
                    viewController.chattingListTableView.snp.makeConstraints { make in
                        make.top.equalTo(self.chattingLabel.snp.bottom).offset(10)
                        make.leading.trailing.bottom.equalToSuperview()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        output.reloadChattingTableView
            .withUnretained(self)
            .subscribe { viewController, _ in
                viewController.chattingListTableView.reloadData()
                viewController.checkChattingEmptyPublisher.onNext(())
            }
            .disposed(by: disposeBag)
    }
}
// MARK: - Paging
extension ChattingTableListController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let contentOffsetY = scrollView.contentOffset.y
        let tableViewContentSizeY = chattingListTableView.contentSize.height
        
        if contentOffsetY > tableViewContentSizeY - scrollView.frame.size.height && !isRefresh {
            chattingListTableView.tableFooterView = footerView
            loadDataPublsher.onNext(())
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self else { return }
                
                chattingListTableView.reloadData()
                chattingListTableView.tableFooterView = nil
            }
        }
    }
}
