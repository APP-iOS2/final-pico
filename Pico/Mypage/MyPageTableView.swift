//
//  MyPageTableView.swift
//  Pico
//
//  Created by 김민기 on 2023/09/26.
//

import RxSwift
import RxCocoa
import SnapKit
import UIKit

protocol MyPageViewDelegate: AnyObject {
    func updateProfileViewLayout(newHeight: CGFloat)
    func tabelDidSelectItem(item: Int)
}

final class MyPageTableView: UITableView {
    
    weak var myPageViewDelegate: MyPageViewDelegate?
    weak var myPageCollectionDelegate: MyPageCollectionDelegate?
    private var viewModel: ProfileViewModel?
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: .insetGrouped)
        configTableView()
        attribute()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configViewModel(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
    }
    
    private func configTableView() {
        self.backgroundColor = .picoLightGray
        self.dataSource = self
        self.delegate = self
    }
    
    private func attribute() {
        self.register(cell: MyPageCollectionTableCell.self)
        self.register(cell: MyPageMatchingTableCell.self)
        self.register(cell: MyPageDefaultTableCell.self)
    }
}

extension MyPageTableView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: MyPageCollectionTableCell.self)
            cell.delegate = myPageCollectionDelegate
            if let viewModel = viewModel {
                cell.configViewModel(viewModel: viewModel)
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: MyPageMatchingTableCell.self)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: MyPageDefaultTableCell.self)
            cell.configure(imageName: "envelope", title: "쪽지 보관함")
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: MyPageDefaultTableCell.self)
            cell.configure(imageName: "person", title: "문의하기")
            return cell
        default:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: MyPageDefaultTableCell.self)
            cell.configure(imageName: "gift", title: "광고보고 츄 받기")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 90
        case 1:
            return 110
        default:
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 20.0
        default:
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myPageViewDelegate?.tabelDidSelectItem(item: indexPath.section)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollOffset = scrollView.contentOffset.y
        let maxHeight = MypageView.profileViewMaxHeight + scrollOffset
        
        let isScreenHeightInsufficient = Screen.height < scrollView.contentSize.height + MypageView.profileViewMaxHeight
        let isProfileViewHeightInRange = (scrollOffset..<maxHeight).contains(MypageView.profileViewHeight)
        
        if isScreenHeightInsufficient && isProfileViewHeightInRange {
            MypageView.profileViewHeight -= scrollOffset
            self.myPageViewDelegate?.updateProfileViewLayout(newHeight: MypageView.profileViewHeight)
            scrollView.contentOffset.y = 0
        }
    }
}
