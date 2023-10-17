//
//  MypageViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import SnapKit

final class MypageViewController: BaseViewController {
    
    private let profileView = ProfileView()
    private let myPageTableView = MyPageTableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configBarItem()
        configTapGesture()
        addViews()
        makeConstraints()
        myPageTableView.myPageCollectionDelegate = self
        myPageTableView.myPageViewDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetTableViewScroll()
        profileView.configProgressBarView()
    }
    
    private func resetTableViewScroll() {
        let indexPath = IndexPath(row: 0, section: 0)
        myPageTableView.scrollToRow(at: indexPath, at: .top, animated: false)
        updateProfileViewLayout(newHeight: MypageView.profileViewMaxHeight)
    }
    
    private func configBarItem() {
        let setButton = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .done, target: self, action: #selector(tappedBarButton))
        setButton.tintColor = .darkGray
    
        navigationItem.rightBarButtonItem = setButton
    }
    
    private func configTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedProfileView))
        profileView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func tappedProfileView(_ sender: UIBarButtonItem) {
        let viewController = ProfileEditViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func tappedBarButton(_ sender: UIBarButtonItem) {
        let viewController = SettingViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func addViews() {
        [profileView, myPageTableView].forEach {
            view.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
    
        profileView.snp.makeConstraints { make in
            make.top.equalTo(safeArea)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(MypageView.profileViewHeight)
        }
        
        myPageTableView.snp.makeConstraints { make in
            make.top.equalTo(profileView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

extension MypageViewController: MyPageViewDelegate {
    
    func updateProfileViewLayout(newHeight: CGFloat) {
        profileView.snp.updateConstraints { make in
            make.height.equalTo(newHeight)
        }
    }
}
extension MypageViewController: MyPageCollectionDelegate {
    func didSelectItem(item: Int) {
        let viewController = StoreViewController(viewModel: StoreViewModel())
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
