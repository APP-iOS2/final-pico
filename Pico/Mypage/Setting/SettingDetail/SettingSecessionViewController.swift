//
//  SettingSecessionViewController.swift
//  Pico
//
//  Created by 김민기 on 2023/10/19.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SettingSecessionViewController: UIViewController {

    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.register(cell: SettingTableCell.self)
        view.configBackgroundColor()
        view.separatorStyle = .none
        view.rowHeight = 50
        return view
    }()

    private let settingSecessionViewModel = SettingSecessionViewModel()
    private let disposeBag: DisposeBag = DisposeBag()
    private let unsubscribePublish = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewConfig()
        addSubView()
        makeConstraints()
        configTableView()
        binds()
    }
    private func configTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
  
    private func viewConfig() {
        title = "회원관리"
        view.configBackgroundColor()
    }
    
    private func addSubView() {
        view.addSubview([tableView])
    }
    
    private func makeConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func binds() {
        
        let input = SettingSecessionViewModel.Input(
            isUnsubscribe: unsubscribePublish.asObservable()
        )
        
        let output = settingSecessionViewModel.transform(input: input)
        
        output.resultIsUnsubscribe
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {  viewController, _ in
                viewController.showCustomAlert(alertType: .onlyConfirm, titleText: "회원탈퇴", messageText: "회원 탈퇴가 완료되었습니다.", confirmButtonText: "확인", comfrimAction: {
                    NotificationService.shared.fcmTokenDelete()
                    UserDefaultsManager.shared.removeAll()
                    let signViewController = UINavigationController(rootViewController: SignViewController())
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootView(signViewController, animated: true)
                })
            }).disposed(by: disposeBag)
    }
}

extension SettingSecessionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: SettingTableCell.self)
        cell.configure(contentLabel: "회원탈퇴", isHiddenNextImage: true)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showCustomAlert(alertType: .canCancel, titleText: "회원탈퇴", messageText: "회원 탈퇴시에는 구매한 츄 및 기타 개인 정보가 삭제되며 환불되지 않습니다.\n회원 탈퇴 후에는 복구가 불가능하오니 신중하게 결정해 주시기를 부탁드립니다.", confirmButtonText: "탈퇴하기", comfrimAction: { [weak self] in
            self?.unsubscribePublish.onNext(())
        })
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
