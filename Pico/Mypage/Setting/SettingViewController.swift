//
//  SettingViewController.swift
//  Pico
//
//  Created by 김민기 on 2023/09/26.
//

import UIKit
import SnapKit
import SafariServices

final class SettingViewController: UIViewController {
    
    enum Settings {
        case allowNotifications
        case allowMarketingNotifications
        case termsOfService
        case privacyPolicy
        case termsOfLocation
        case openSourceLicense
        case businessInformation
        case louout
        case accountManagement
            
        var name: String {
            switch self {
            case .allowNotifications:
                return "전체 알림 허용"
            case .allowMarketingNotifications:
                return "마케팅 알림 허용"
            case .termsOfService:
                return "서비스 이용약관"
            case .privacyPolicy:
                return "개인정보 처리방침"
            case .termsOfLocation:
                return "위치정보 이용약관"
            case .openSourceLicense:
                return "오픈소스 라이센스"
            case .businessInformation:
                return "사업자 정보"
            case .louout:
                return "로그아웃"
            case .accountManagement:
                return "계정관리"
            }
        }
        var urlString: String {
            switch self {
            case .termsOfService:
                return "https://blue-coal-c5c.notion.site/b39af82a049345dda5b86da5f3f0081d?pvs=4"
            case .privacyPolicy:
                return "https://blue-coal-c5c.notion.site/b51dfe467cc148c08b35b45987965a9d?pvs=4"
            case .termsOfLocation:
                return "https://blue-coal-c5c.notion.site/b427e62683124e94855663c1b5756866?pvs=4"
            case .businessInformation:
                return "https://github.com/APPSCHOOL3-iOS"
            default:
                return ""
            }
        }
    }
    
    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.register(cell: SettingPrivateTableCell.self)
        view.register(cell: SettingNotiTableCell.self)
        view.register(cell: SettingTableCell.self)
        view.configBackgroundColor()
        view.separatorStyle = .none
        return view
    }()
    private var notiState = false
    private var notiMarketinState = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavigation()
        configTableView()
        addViews()
        makeConstraints()
        configNavigationBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let isPushOn = UIApplication.shared.isRegisteredForRemoteNotifications
        if !isPushOn {
            notiState = true
            notiMarketinState = true
        } else {
            notiState = false
            notiMarketinState = false
        }
        tableView.reloadData()
    }
    
    private func configNavigation() {
        title = "설정"
    }
    
    private func configTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func addViews() {
        [tableView].forEach {
            view.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func presentSafariView(urlString: String) {
        guard let url = URL(string: urlString) else {return}
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.modalPresentationStyle = .automatic
        present(safariViewController, animated: true)
    }
    
    private func pushNextViewController(viewController: UIViewController) {
        let viewController = viewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func logout() {
        /*
         let firebaseAuth = Auth.auth()
         do {
         try firebaseAuth.signOut()
         } catch let signOutError as NSError {
         print("Error signing out: %@", signOutError)
         }
         */
        
        NotificationService.shared.fcmTokenDelete()
        UserDefaultsManager.shared.removeAll()
        let signViewController = UINavigationController(rootViewController: SignViewController())
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootView(signViewController, animated: true)
    }
}

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 5
        case 2:
            return 2
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: SettingNotiTableCell.self)
            
            switch indexPath.row {
            case 0:
                cell.configure(titleLabel: Settings.allowNotifications.name, subTitleLabel: "PICO의 모든 알림을 허용합니다", state: notiState)
            case 1:
                cell.configure(titleLabel: Settings.allowMarketingNotifications.name, subTitleLabel: "마케팅 알림을 허용합니다", state: notiMarketinState)
            default:
                break
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: SettingTableCell.self)
            switch indexPath.row {
            case 0:
                cell.configure(contentLabel: Settings.termsOfService.name)
            case 1:
                cell.configure(contentLabel: Settings.privacyPolicy.name)
            case 2:
                cell.configure(contentLabel: Settings.termsOfLocation.name)
            case 3:
                cell.configure(contentLabel: Settings.openSourceLicense.name)
            case 4:
                cell.configure(contentLabel: Settings.businessInformation.name)
            default:
                break
            }
            
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: SettingTableCell.self)
            switch indexPath.row {
            case 0:
                cell.configure(contentLabel: Settings.louout.name, isHiddenNextImage: true)
            case 1:
                cell.configure(contentLabel: Settings.accountManagement.name)
            default:
                break
            }
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 75
        case 1, 2:
            return 40
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SettingTableHeaderView()
        switch section {
        case 0:
            view.configure(headerLabel: "알림")
        case 1:
            view.configure(headerLabel: "약관")
        case 2:
            view.configure(headerLabel: "계정")
        default:
            return nil
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        default:
            return 20.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 0:
                presentSafariView(urlString: Settings.termsOfService.urlString)
            case 1:
                presentSafariView(urlString: Settings.privacyPolicy.urlString)
            case 2:
                presentSafariView(urlString: Settings.termsOfLocation.urlString)
            case 3:
                pushNextViewController(viewController: SettingLicenseViewController())
            case 4:
                presentSafariView(urlString: Settings.businessInformation.urlString)
            default: break
            }
        case 2:
            switch indexPath.row {
            case 0:
                logout()
            case 1:
                pushNextViewController(viewController: SettingSecessionViewController())
               
            default:
                break
            }
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
