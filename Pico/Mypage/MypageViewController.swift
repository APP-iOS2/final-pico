//
//  MypageViewController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import SnapKit
import SafariServices
import MessageUI

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
        myPageTableView.configViewModel(viewModel: profileViewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetTableViewScroll()
        profileView.configProgressBarView()
        profileViewModel.loadChuCount()
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
    
    private func presentViewController(_ viewController: UIViewController) {
        let viewController = viewController
        viewController.modalPresentationStyle = .automatic
        present(viewController, animated: true)
    }
    
    private func presentEmail() {
           if MFMailComposeViewController.canSendMail() {
               let composeViewController = MFMailComposeViewController()
               composeViewController.mailComposeDelegate = self
               let bodyString = "문의 내용을 작성해주세요."
                   composeViewController.setSubject(" PICO 문의")
               
               composeViewController.setToRecipients(["rlaalsrl1227@gmail.com"])
               composeViewController.setMessageBody(bodyString, isHTML: false)
               
               self.present(composeViewController, animated: true, completion: nil)
               
           } else {
               showCustomAlert(alertType: .canCancel, titleText: "문의하기 실패", messageText: "문의를 보내려면 'Mail' 앱이 필요합니다. App Store에서 해당 앱을 복원하거나 이메일 설정을 확인하고 다시 시도해주세요.", confirmButtonText: "App Store로 이동하기", comfrimAction: {
                   if let url = URL(string: "https://apps.apple.com/kr/app/mail/id1108187098"), UIApplication.shared.canOpenURL(url) {
                       if #available(iOS 10.0, *) {
                           UIApplication.shared.open(url, options: [:], completionHandler: nil)
                       } else {
                           UIApplication.shared.openURL(url)
                       }
                   }
               })
           }
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
        switch item {
        case 1:
            presentViewController(PremiumViewController())
        case 2:
            presentEmail()
        case 3:
            presentViewController(AdvertisementViewController())
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
            presentViewController(SFSafariViewController(url: url))
        default:
            break
        }
    }
}

extension MypageViewController : MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated:true,completion: nil)
    }
}
