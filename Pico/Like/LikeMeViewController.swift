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
    private let refreshPublisher = PublishSubject<Void>()
    private let loadDataPublsher = PublishSubject<Void>()
    private let listLoadPublisher = PublishSubject<Void>()
    private let deleteUserPublisher = PublishSubject<String>()
    private let likeUserPublisher = PublishSubject<String>()
    private var isLoading = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewModel.likeMeList.isEmpty {
            refreshPublisher.onNext(())
        }
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configCollectionView()
        bind()
        configRefresh()
        loadDataPublsher.onNext(())
    }
    
    private func configCollectionView() {
        collectionView.register(cell: LikeCollectionViewCell.self)
        collectionView.register(cell: CollectionViewFooterLoadingCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func configRefresh() {
        refreshControl.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        refreshControl.tintColor = .picoBlue
        collectionView.refreshControl = refreshControl
    }
    
    @objc private func refreshTable(refresh: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            refreshPublisher.onNext(())
            refresh.endRefreshing()
        }
    }
}

extension LikeMeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isLoading ? viewModel.likeMeList.count + 1 : viewModel.likeMeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isLoading && indexPath.row == viewModel.likeMeList.count {
            let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath, cellType: CollectionViewFooterLoadingCell.self)
            cell.startLoading()
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath, cellType: LikeCollectionViewCell.self)
            let item = viewModel.likeMeList[indexPath.row]
            cell.configData(image: item.imageURL, nameText: "\(item.nickName), \(item.age)", isHiddenDeleteButton: false, isHiddenMessageButton: true, mbti: item.mbti)
            
            cell.deleteButtonTapObservable
                .subscribe(onNext: { [weak self] in
                    self?.showAlert(message: "\(item.nickName)님을 disLike합니다.", isCancelButton: true, yesAction: {
                        self?.deleteUserPublisher.onNext(item.likedUserId)
                    })
                })
                .disposed(by: cell.disposeBag)
            
            cell.likeButtonTapObservalbe
                .subscribe(onNext: { [weak self] in
                    self?.showAlert(message: "\(item.nickName)님께 좋아요를 보냅니다.\n 바로 매칭되어 쪽지가 가능합니다.", isCancelButton: true, yesAction: {
                        self?.likeUserPublisher.onNext(item.likedUserId)
                    })
                })
                .disposed(by: cell.disposeBag)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 디테일뷰 유저정보 연결 필요
        let viewController = UserDetailViewController()
        // user정보 넘겨주세여
        //viewController.viewModel = UserDetailViewModel(user: user)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isLoading && indexPath.row == viewModel.likeMeList.count {
            return CGSize(width: view.frame.width, height: 50)
        } else {
            let width = view.frame.width / 2 - 17.5
            return CGSize(width: width, height: width * 1.5)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    // MARK: - 페이징 처리
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let contentOffsetY = scrollView.contentOffset.y
        let collectionViewContentSizeY = collectionView.contentSize.height
        
        if contentOffsetY > collectionViewContentSizeY - scrollView.frame.size.height {
            self.isLoading = true
            self.collectionView.reloadData()
            listLoadPublisher.onNext(())
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                self.isLoading = false
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

// MARK: - Bind
extension LikeMeViewController {
    private func bind() {
        let input = LikeMeViewModel.Input(listLoad: loadDataPublsher, refresh: refreshPublisher, deleteUser: deleteUserPublisher, likeUser: likeUserPublisher)
        let output = viewModel.transform(input: input)
        
        output.likeUIsEmpty
            .withUnretained(self)
            .subscribe(onNext: { viewController, isEmpty in
                if isEmpty {
                    viewController.addChild(viewController.emptyView)
                    viewController.view.addSubview(viewController.emptyView.view ?? UIView())
                    viewController.emptyView.didMove(toParent: self)
                    viewController.emptyView.view.snp.makeConstraints { make in
                        make.edges.equalToSuperview()
                    }
                } else {
                    viewController.view.addSubview(viewController.collectionView)
                    viewController.collectionView.snp.makeConstraints { make in
                        make.top.leading.equalToSuperview().offset(10)
                        make.trailing.bottom.equalToSuperview().offset(-10)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        output.reloadCollectionView
            .withUnretained(self)
            .subscribe { viewController, _ in
                viewController.collectionView.reloadData()
            }
            .disposed(by: disposeBag)
    }
}
