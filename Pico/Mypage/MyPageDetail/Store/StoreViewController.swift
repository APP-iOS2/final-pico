//
//  StoreViewController.swift
//  Pico
//
//  Created by 김민기 on 2023/09/26.
//

import UIKit
import SnapKit
import RxSwift

final class StoreViewController: UIViewController {
    
    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.backgroundColor = .clear
        view.addShadow(offset: CGSize(width: 3, height: 5), opacity: 0.2, radius: 5)
        return view
    }()
    
    private let viewModel: StoreViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let purchaseChuCountPublish = PublishSubject<Int>()
    private let consumeChuCountPublish = PublishSubject<Int>()
    
    init(viewModel: StoreViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        configTableView()
        addViews()
        makeConstraints()
        bind()
    }
    
    private func configView() {
        title = "Store"
        view.configBackgroundColor()
    }
    
    private func configTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cell: StoreTableCell.self)
    }
    
    private func bind() {
        let input = StoreViewModel.Input(
            purchaseChuCount: purchaseChuCountPublish.asObservable(),
            consumeChuCount: consumeChuCountPublish.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output.resultPurchase
            .withUnretained(self)
            .subscribe { viewController, _ in
                viewController.showCustomAlert(alertType: .onlyConfirm, titleText: "결제 확인", messageText: "결제되셨습니다.", confirmButtonText: "확인", comfrimAction: {
                    viewController.navigationController?.popViewController(animated: true)
                })
            }
            .disposed(by: disposeBag)
    }
    
    private func addViews() {
        view.addSubview(tableView)
    }
    
    private func makeConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension StoreViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: StoreTableCell.self)
        guard let storeModel = viewModel.storeModels[safe: indexPath.section] else { return UITableViewCell() }
        
        cell.configure(storeModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.showCustomAlert(alertType: .canCancel, titleText: "결제 알림", messageText: "결제하시겠습니까 ?", confirmButtonText: "결제", comfrimAction: { [weak self] in
            guard let self = self else { return }
            
            let purchaseChuCount = viewModel.storeModels[indexPath.section].count
            purchaseChuCountPublish.onNext(purchaseChuCount)
        })
    }
}
