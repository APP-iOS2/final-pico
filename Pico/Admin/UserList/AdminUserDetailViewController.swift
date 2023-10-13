//
//  AdminUserDetailViewController.swift
//  Pico
//
//  Created by 최하늘 on 10/12/23.
//

import UIKit
import SnapKit

struct UserImage {
    static let height: CGFloat = Screen.height * 0.6
}

final class AdminUserDetailViewController: UIViewController {

    private let topView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let backButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let backImage = UIImage(systemName: "chevron.left", withConfiguration: imageConfig)
        let button = UIButton(type: .system)
        button.setImage(backImage, for: .normal)
        button.tintColor = .picoBlue
        return button
    }()
    
    private let tableView: UITableView = UITableView()
    
    private var user: User!
    
    init(user: User) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.configBackgroundColor()
        addViews()
        makeConstraints()
        configTableView()
        configButtons()
    }
    
    private func configTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cell: DetailUserImageTableViewCell.self)
        tableView.register(cell: DetailUserInfoTableViewCell.self)
        tableView.register(cell: NotificationTableViewCell.self)
        tableView.separatorStyle = .none
    }
    
    private func configButtons() {
        backButton.addTarget(self, action: #selector(tappedBackButton), for: .touchUpInside)
    }
    
    @objc private func tappedBackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension AdminUserDetailViewController: UITableViewDelegate, UITableViewDataSource {
    enum TableViewCase: CaseIterable {
        case image
        case info
        case record
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tableViewCase = TableViewCase.allCases[safe: section] else { return 0 }
        
        switch tableViewCase {
        case .image:
            return 1
        case .info:
            return 1
        case .record:
            return 10
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return TableViewCase.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tableViewCase = TableViewCase.allCases[safe: indexPath.section] else { return UITableViewCell()}

        switch tableViewCase {
        case .image:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: DetailUserImageTableViewCell.self)
            cell.config(images: user.imageURLs)
            cell.selectionStyle = .none
            return cell

        case .info:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: DetailUserInfoTableViewCell.self)
            cell.config(user: user)
            cell.selectionStyle = .none
            return cell
            
        case .record:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: NotificationTableViewCell.self)
            guard let imageURL = user.imageURLs[safe: 0] else { return UITableViewCell() }
            cell.configData(notitype: .report, imageUrl: imageURL, nickName: user.nickName, age: user.age, mbti: user.mbti, date: user.createdDate)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let tableViewCase = TableViewCase.allCases[safe: indexPath.section] else { return 0 }
        
        switch tableViewCase {
        case .image:
            return UserImage.height
        case .info:
            return UITableView.automaticDimension
        case .record:
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let tableViewCase = TableViewCase.allCases[safe: section] else { return UIView() }
        
        if tableViewCase == .record {
            let headerView = RecordHeaderCollectionView()
            headerView.backgroundColor = .red

            return headerView
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let tableViewCase = TableViewCase.allCases[safe: section] else { return 0 }
        if tableViewCase == .record {
            return 80.0
        }
        return 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let maxAlpha = 0.7
        let maxHeight = UserImage.height
        
        switch offset {
        case ...0:
            topView.backgroundColor = .clear
        case 1...maxHeight:
            let alpha = offset * maxAlpha / maxHeight
            topView.backgroundColor = .systemBackground.withAlphaComponent(alpha)
        default:
            topView.backgroundColor = .systemBackground.withAlphaComponent(maxAlpha)
        }
    }
}

extension AdminUserDetailViewController {
    private func addViews() {
        view.addSubview([tableView, topView])
        topView.addSubview(backButton)
    }
    
    private func makeConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        topView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        backButton.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.width.equalTo(topView.snp.height)
            make.height.equalTo(topView.snp.height)
        }
    }
}
