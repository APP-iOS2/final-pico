//
//  LikeUViewController.swift
//  Pico
//
//  Created by 방유빈 on 2023/09/25.
//

import UIKit
import RxSwift
import RxCocoa

final class LikeUViewController: UIViewController {
    private let emptyView: EmptyViewController = EmptyViewController(type: .iLikeU)
    private let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let viewModel: LikeUViewModel = LikeUViewModel()
    private let disposeBag: DisposeBag = DisposeBag()
    
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
    }
    
    private func configCollectionView() {
        collectionView.register(cell: LikeCollectionViewCell.self)
    }
    
    private func addViews() {
        viewModel.likeUIsEmpty
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
        viewModel.likeUIsEmpty
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
}

extension LikeUViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width / 2 - 17.5
        return CGSize(width: width, height: width * 1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
}

// MARK: - UITableView+Rx
extension LikeUViewController {
    private func configCollectionviewDatasource() {
        viewModel.likeUUserList
            .bind(to: collectionView.rx.items(cellIdentifier: LikeCollectionViewCell.reuseIdentifier, cellType: LikeCollectionViewCell.self)) { _, item, cell in
                cell.configData(image: item.imageURL, nameText: "\(item.nickName), \(item.age)", isHiddenDeleteButton: true, isHiddenMessageButton: false, mbti: item.mbti)
                cell.messageButtonTapObservable
                    .subscribe(onNext: { [weak self] in
                        // 메일 뷰 데이터 연결 후 userId 값 넘겨주기
                        let mailSendView = MailSendViewController()
                        mailSendView.modalPresentationStyle = .formSheet
                        self?.present(mailSendView, animated: true, completion: nil)
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
                // 디테일뷰 데이터 연결 후 UserId 값 넘겨주기
                let viewController = UserDetailViewController()
                self.navigationController?.pushViewController(viewController, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
