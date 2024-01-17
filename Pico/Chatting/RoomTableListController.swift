//
//  RoomTableListController.swift
//  Pico
//
//  Created by 양성혜 on 2023/12/16.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class RoomTableListController: BaseViewController {
    
    private let viewModel = RoomViewModel()
    private let disposeBag = DisposeBag()
    private let emptyView: EmptyViewController = EmptyViewController(type: .message)
    private let refreshControl = UIRefreshControl()
    private let refreshPublisher = PublishSubject<Void>()
    private let loadDataPublsher = PublishSubject<Void>()
    private let checkRoomEmptyPublisher = PublishSubject<Void>()
    private let footerView = FooterView()
    private var isRefresh = false
    private var nickname = ""
    
    private let roomListTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(cell: RoomListTableViewCell.self)
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
        checkRoomEmptyPublisher.onNext(())
        refreshPublisher.onNext(())
        roomListTableView.reloadData()
    }
    // MARK: - config
    
    private func configTableView() {
        footerView.frame = CGRect(x: 0, y: 0, width: roomListTableView.bounds.size.width, height: 80)
        roomListTableView.dataSource = self
        roomListTableView.delegate = self
    }
    
    private func configRefresh() {
        refreshControl.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        refreshControl.tintColor = .picoBlue
        roomListTableView.refreshControl = refreshControl
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
extension RoomTableListController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.roomList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: RoomListTableViewCell.self)
        guard let item = viewModel.roomList[safe: indexPath.row] else { return UITableViewCell() }
        nickname = cell.config(roomInfo: item)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let room = viewModel.roomList[safe: indexPath.row] else { return }
        
        let chattingDetailView = ChattingDetailViewController(roomId: room.roomId, opponentId: room.opponentId)
        chattingDetailView.configData(roomInfo: room)
        chattingDetailView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chattingDetailView, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
// MARK: - bind
extension RoomTableListController {
    private func bind() {
        
        let input = RoomViewModel.Input(
            listLoad: loadDataPublsher,
            refresh: refreshPublisher,
            isRoomEmptyChecked: checkRoomEmptyPublisher)
        let output = viewModel.transform(input: input)
        
        let safeArea = view.safeAreaLayoutGuide
        
        output.roomIsEmpty
            .withUnretained(self)
            .subscribe(onNext: { viewController, isEmpty in
                if isEmpty {
                    viewController.addChild(viewController.emptyView)
                    viewController.view.addSubview([viewController.emptyView.view ?? UIView()])
                    viewController.emptyView.didMove(toParent: self)
                    viewController.emptyView.view.snp.makeConstraints { make in
                        make.top.equalTo(safeArea)
                        make.leading.trailing.bottom.equalToSuperview()
                    }
                } else {
                    viewController.view.addSubview([viewController.roomListTableView])
                    viewController.roomListTableView.snp.makeConstraints { make in
                        make.top.equalTo(safeArea)
                        make.leading.trailing.bottom.equalToSuperview()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        output.reloadRoomTableView
            .withUnretained(self)
            .subscribe { viewController, _ in
                viewController.roomListTableView.reloadData()
                viewController.checkRoomEmptyPublisher.onNext(())
            }
            .disposed(by: disposeBag)
    }
}
// MARK: - Paging
extension RoomTableListController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let contentOffsetY = scrollView.contentOffset.y
        let tableViewContentSizeY = roomListTableView.contentSize.height
        
        if contentOffsetY > tableViewContentSizeY - scrollView.frame.size.height && !isRefresh {
            roomListTableView.tableFooterView = footerView
            loadDataPublsher.onNext(())
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self else { return }
                
                roomListTableView.reloadData()
                roomListTableView.tableFooterView = nil
            }
        }
    }
}
