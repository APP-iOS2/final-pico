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
        view.showsVerticalScrollIndicator = false
        view.addShadow(offset: CGSize(width: 3, height: 5), opacity: 0.2, radius: 5)
        return view
    }()
    
    private let naviView = UIView()
    
    private let chuImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "chu")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let chuCountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .picoDescriptionFont
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.picoDescriptionFont
        label.text = "꽝은 절대 없다!\n랜덤박스를 열어 부족한 츄를 획득해보세요!"
        label.numberOfLines = 0
        return label
    }()
    
    private let viewModel: StoreViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    private var currentChuCount = 0
    private let purchaseChuCountPublish = PublishSubject<StoreModel>()
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
        configNavigationItem()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chuCountLabel.text = "\(UserDefaultsManager.shared.getChuCount())"
    }
    private func configView() {
        title = "Store"
        view.configBackgroundColor()
    }
    
    private func configTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cell: StoreTableCell.self)
        tableView.register(cell: StoreTableBannerCell.self)
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
                sleep(2)
                DispatchQueue.main.async {
                    viewController.showCustomAlert(alertType: .onlyConfirm, titleText: "결제 확인", messageText: "결제되셨습니다.", confirmButtonText: "확인", comfrimAction: {
                        viewController.navigationController?.popViewController(animated: true)
                        print(UserDefaultsManager.shared.getChuCount())
                    })
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func configNavigationItem() {
        chuCountLabel.text = "\(currentChuCount)"
        naviView.addSubview([chuImageView, chuCountLabel])
        
        chuImageView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(chuCountLabel.snp.leading)
            make.width.height.equalTo(25)
            
        }
        
        chuCountLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-6)
        }
        
        let rightItem = UIBarButtonItem(customView: naviView)
             navigationItem.rightBarButtonItem = rightItem
    }
    
    private func addViews() {
      
        view.addSubview([tableView])
        
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
        return viewModel.storeModels.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: StoreTableBannerCell.self)
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: StoreTableCell.self)
            guard let storeModel = viewModel.storeModels[safe: indexPath.section - 1] else { return UITableViewCell() }
            
            cell.configure(storeModel)
            return cell
        }
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
        switch indexPath.section {
        case 0:
            break
        default:
            self.showCustomAlert(alertType: .canCancel, titleText: "결제 알림", messageText: "결제하시겠습니까 ?", confirmButtonText: "결제", comfrimAction: { [weak self] in
                guard let self = self else { return }
                guard let storeModel = viewModel.storeModels[safe: indexPath.section - 1] else { return }
                
                purchaseChuCountPublish.onNext(storeModel)
            })
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
