//
//  LikeMeViewController.swift
//  Pico
//
//  Created by 방유빈 on 2023/09/25.
//

import UIKit
import RxSwift
import RxCocoa

final class LikeMeViewController: UIViewController {
    private let emptyView = EmptyViewController(type: .uLikeMe)
    private let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let viewModel: LikeMeViewModel = LikeMeViewModel()
    private let disposeBag: DisposeBag = DisposeBag()
    private let refreshControl = UIRefreshControl()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        makeConstraints()
        configCollectionView()
        configCollectionviewDatasource()
        configCollectionviewDelegate()
        configRefresh()
    }
    
    private func configCollectionView() {
        collectionView.register(cell: LikeCollectionViewCell.self)
    }
    
    private func configRefresh() {
        refreshControl.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        refreshControl.tintColor = .picoBlue
        collectionView.refreshControl = refreshControl
    }
    
    private func addViews() {
        viewModel.likeMeIsEmpty
            .subscribe(onNext: { [weak self] isEmpty in
                if isEmpty {
                    self?.addChild(self?.emptyView ?? UIViewController())
                    self?.view.addSubview(self?.emptyView.view ?? UIView())
                    self?.emptyView.didMove(toParent: self)
                } else {
                    self?.view.addSubview(self?.collectionView ?? UICollectionView())
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func makeConstraints() {
        viewModel.likeMeIsEmpty
            .subscribe(onNext: { [weak self] isEmpty in
                if isEmpty {
                    self?.emptyView.view.snp.makeConstraints { make in
                        make.edges.equalToSuperview()
                    }
                } else {
                    self?.collectionView.snp.makeConstraints { make in
                        make.top.leading.equalToSuperview().offset(10)
                        make.trailing.bottom.equalToSuperview().offset(-10)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    @objc func refreshTable(refresh: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            viewModel.refrsh()
            refresh.endRefreshing()
        }
    }
}

extension LikeMeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width / 2 - 17.5
        return CGSize(width: width, height: width * 1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
}

// MARK: - UITableView+Rx
extension LikeMeViewController {
    private func configCollectionviewDatasource() {
        viewModel.likeMeListRx
            .bind(to: collectionView.rx.items(cellIdentifier: LikeCollectionViewCell.reuseIdentifier, cellType: LikeCollectionViewCell.self)) { _, item, cell in
                cell.configData(image: item.imageURL, nameText: "\(item.nickName), \(item.age)", isHiddenDeleteButton: false, isHiddenMessageButton: true, mbti: item.mbti)
                
                cell.deleteButtonTapObservable
                    .subscribe(onNext: { [weak self] in
                        self?.showAlert(message: "\(item.nickName)님을 disLike합니다.", isCancelButton: true, yesAction: {
                            self?.viewModel.deleteUser(userId: item.likedUserId)
                        })
                    })
                    .disposed(by: cell.disposeBag)
                
                cell.likeBurttonTapObservalbe
                    .subscribe(onNext: { [weak self] in
                        self?.showAlert(message: "\(item.nickName)님께 좋아요를 보냅니다.\n 바로 매칭되어 쪽지가 가능합니다.", isCancelButton: true, yesAction: {
                            self?.viewModel.likeUser(userId: item.likedUserId)
                        })
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
    }
    
    private func configCollectionviewDelegate() {
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        collectionView.rx.modelSelected(Like.LikeInfo.self)
            .subscribe(onNext: { _ in
                // 디테일 뷰 데이터 완성 후 User 정보 연결
                let viewController = UserDetailViewController()
                self.navigationController?.pushViewController(viewController, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
