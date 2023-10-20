//
//  MypageViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import SnapKit
import SafariServices

final class MypageViewController: BaseViewController {
    
    private let profileView = ProfileView()
    private let myPageTableView = MyPageTableView()
    private let profileViewModel = ProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configBarItem()
        configTapGesture()
        addViews()
        makeConstraints()
        myPageTableView.myPageCollectionDelegate = self
        myPageTableView.myPageViewDelegate = self
        profileView.configViewModel(viewModel: profileViewModel)
        profileViewModel.loadUserData()
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
        profileView.configBaseView(gesture: tapGesture)
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
    private func pushNextViewController(_ viewController: UIViewController) {
        let viewController = viewController
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func tappedProfileView(_ sender: UIBarButtonItem) {
        pushNextViewController(ProfileEditViewController(profileViewModel: profileViewModel))
    }
    
    @objc private func tappedBarButton(_ sender: UIBarButtonItem) {
        pushNextViewController(SettingViewController())
    }
}

extension MypageViewController: MyPageViewDelegate {
    func updateProfileViewLayout(newHeight: CGFloat) {
        profileView.snp.updateConstraints { make in
            make.height.equalTo(newHeight)
        }
    }
    func tabelDidSelectItem(item: Int) {
        print(item)
        switch item {
        case 1:
            pushNextViewController(PremiumViewController())
        case 2:
           break
        case 3:
            pushNextViewController(AdvertisementViewController())
        default:
            break
        }
    }
}
extension MypageViewController: MyPageCollectionDelegate {
    func didSelectItem(item: Int) {
        switch item {
        case 0:
            pushNextViewController(StoreViewController(viewModel: StoreViewModel()))
        case 1:
            guard let url = URL(string: "https://www.16personalities.com/ko/%EB%AC%B4%EB%A3%8C-%EC%84%B1%EA%B2%A9-%EC%9C%A0%ED%98%95-%EA%B2%80%EC%82%AC") else {return}
            let safariViewController = SFSafariViewController(url: url)
            safariViewController.modalPresentationStyle = .automatic
            present(safariViewController, animated: true)
        default:
            break
        }
    }
}
