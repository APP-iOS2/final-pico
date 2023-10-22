//
//  LikeUViewController.swift
//  Pico
//
//  Created by 방유빈 on 2023/09/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class LikeUViewController: UIViewController {
    private let emptyView: EmptyViewController = EmptyViewController(type: .iLikeU)
    private let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let viewModel: LikeUViewModel = LikeUViewModel()
    private let disposeBag: DisposeBag = DisposeBag()
    private let refreshControl = UIRefreshControl()
    private let listLoadPublisher = PublishSubject<Void>()
    private let refreshPublisher = PublishSubject<Void>()
    private let checkEmptyPublisher = PublishSubject<Void>()
    private let sendMessagePublisher = PublishSubject<Int>()
    private let pushSendConrollerPublisher = PublishSubject<Void>()
    private var isLoading = false
    private var isRefresh = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewModel.likeUList.isEmpty {
            refreshPublisher.onNext(())
        }
        collectionView.reloadData()
        checkEmptyPublisher.onNext(())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configCollectionView()
        configRefresh()
        listLoadPublisher.onNext(())
    }
    
    private func configCollectionView() {
        collectionView.register(cell: LikeCollectionViewCell.self)
        collectionView.register(CollectionViewFooterLoadingCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)
    }
    
    private func configRefresh() {
        refreshControl.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        refreshControl.tintColor = .picoBlue
        collectionView.refreshControl = refreshControl
    }
    
    @objc func refreshTable(refresh: UIRefreshControl) {
        isRefresh = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            refreshPublisher.onNext(())
            refresh.endRefreshing()
            isRefresh = false
        }
    }
}

extension LikeUViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.likeUList.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath, cellType: LikeCollectionViewCell.self)
        guard let item = viewModel.likeUList[safe: indexPath.row] else { return cell }
        cell.configData(image: item.imageURL, nameText: "\(item.nickName), \(item.age)", isHiddenDeleteButton: true, isHiddenMessageButton: false, mbti: item.mbti)
        cell.messageButtonTapObservable
            .withUnretained(self)
            .subscribe { viewController, _ in
                viewController.showCustomAlert(alertType: .canCancel, titleText: "메일 보내기", messageText: "매칭되지 않은 사용자에게 메일을 보내기 위해서는 50츄가 필요합니다. \n현재 츄 : \(UserDefaultsManager.shared.getChuCount()) 개", confirmButtonText: "보내기 (50츄)", comfrimAction: {
                    let resultChu = UserDefaultsManager.shared.getChuCount() - 50
                    if resultChu < 0 {
                        viewController.showCustomAlert(alertType: .canCancel, titleText: "보유 츄 부족", messageText: "보유하고 있는 츄가 부족합니다. \n현재 츄 : \(UserDefaultsManager.shared.getChuCount()) 개", cancelButtonText: "보내기 취소", confirmButtonText: "스토어로 이동", comfrimAction: {
                            let storeViewController = StoreViewController(viewModel: StoreViewModel())
                            viewController.navigationController?.pushViewController(storeViewController, animated: true)
                        })
                    } else {
                        viewController.sendMessagePublisher.onNext(50)
                        viewController.pushSendConrollerPublisher
                            .subscribe(onNext: { _ in
                                let mailSendView = MailSendViewController()
                                mailSendView.configData(userId: item.likedUserId, atMessageView: false)
                                mailSendView.modalPresentationStyle = .formSheet
                                self.present(mailSendView, animated: true, completion: nil)
                            })
                            .disposed(by: cell.disposeBag)
                    }
                })
            }
            .disposed(by: cell.disposeBag)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = UserDetailViewController()
        guard let selectedUser = viewModel.likeUList[safe: indexPath.row] else { return }
        FirestoreService.shared.loadDocument(collectionId: .users, documentId: selectedUser.likedUserId, dataType: User.self) { result in
            switch result {
            case .success(let data):
                guard let data = data else { return }
                viewController.viewModel = UserDetailViewModel(user: data)
                self.navigationController?.pushViewController(viewController, animated: true)
            case .failure(let error):
                print(error)
                return
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            guard let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer", for: indexPath) as? CollectionViewFooterLoadingCell else {
                return CollectionViewFooterLoadingCell()
            }
            footer.startLoading()  
            return footer
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if isLoading {
            return CGSize(width: view.frame.size.width, height: 50)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width / 2 - 17.5
        return CGSize(width: width, height: width * 1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
}

// MARK: - 페이징 처리
extension LikeUViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let contentOffsetY = scrollView.contentOffset.y
        let collectionViewContentSizeY = collectionView.contentSize.height
        
        if contentOffsetY > collectionViewContentSizeY - scrollView.frame.size.height && !isRefresh {
            self.isLoading = true
            self.collectionView.reloadData()
            self.listLoadPublisher.onNext(())
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                self.isLoading = false
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

// MARK: - bind
extension LikeUViewController {
    private func bind() {
        let input = LikeUViewModel.Input(listLoad: listLoadPublisher, refresh: refreshPublisher, checkEmpty: checkEmptyPublisher, sendMessage: sendMessagePublisher)
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
                        make.top.bottom.equalToSuperview()
                        make.leading.equalToSuperview().offset(10)
                        make.trailing.equalToSuperview().offset(-10)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        output.reloadCollectionView
            .withUnretained(self)
            .subscribe { viewController, _ in
                viewController.collectionView.reloadData()
                viewController.checkEmptyPublisher.onNext(())
            }
            .disposed(by: disposeBag)
        
        output.resultMessage
            .withUnretained(self)
            .subscribe { viewController, _ in
                viewController.pushSendConrollerPublisher.onNext(())
            }
            .disposed(by: disposeBag)
    }
}
