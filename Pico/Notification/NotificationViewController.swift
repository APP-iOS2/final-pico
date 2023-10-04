//
//  NotificationViewController.swift
//  Pico
//
//  Created by 방유빈 on 2023/09/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

final class NotificationViewController: UIViewController {
    private let tableView = UITableView()
    private let viewModel = NotificationViewModel()
    private var disposeBag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configViewController()
        addViews()
        makeConstraints()
        configTableView()
        configTableviewDelegate()
        configTableviewDatasource()
    }
    
    private func configViewController() {
        navigationItem.title = "알림"
        view.backgroundColor = .systemBackground
    }
    
    private func configTableView() {
        tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: Identifier.TableCell.notiTableCell)
        if #available(iOS 15.0, *) {
            tableView.tableHeaderView = UIView()
        }
    }
    
    private func addViews() {
        view.addSubview(tableView)
    }
    
    private func makeConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension NotificationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - UITableView+Rx
extension NotificationViewController {
    private func configTableviewDatasource() {
        viewModel.notifications
            .bind(to: tableView.rx.items(cellIdentifier: Identifier.TableCell.notiTableCell, cellType: NotificationTableViewCell.self)) { _, item, cell in
                cell.nameLabel.text = item.name
                cell.notiType = item.notiType
                cell.iconImageView.image = item.notiType == .like ? UIImage(systemName: "heart.fill") : UIImage(systemName: "message.fill")
                cell.iconImageView.tintColor = item.notiType == .like ? .systemPink : .picoBlue
                cell.contentLabel.text = item.notiType == .like ? "좋아요를 누르셨습니다." : "쪽지를 보냈습니다."
                Observable.just(item.imageUrl)
                    .flatMap(self.imageLoad)
                    .observe(on: MainScheduler.instance)
                    .bind(to: cell.profileImageView.rx.image)
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
    }
    
    private func configTableviewDelegate() {
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        tableView.rx.modelSelected(DummyNoti.self)
            .subscribe(onNext: { item in
                if item.notiType == .like {
                    let viewController = UserDetailViewController()
                    self.navigationController?.pushViewController(viewController, animated: true)
                } else {
                    if let tabBarController = self.tabBarController as? TabBarController {
                        tabBarController.selectedIndex = 1
                        let viewControllers = self.navigationController?.viewControllers
                        self.navigationController?.setViewControllers(viewControllers ?? [], animated: false)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func imageLoad(url: String) -> Observable<UIImage?> {
        return Observable.create { emitter in
            let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, _, error in
                if let error = error {
                    emitter.onError(error)
                    return
                }
                guard let data = data,
                      let image = UIImage(data: data) else {
                    emitter.onNext(nil)
                    emitter.onCompleted()
                    return
                }
                
                emitter.onNext(image)
                emitter.onCompleted()
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
