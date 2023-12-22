//
//  SceneDelegate.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import FirebaseMessaging

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var rootViewController: UIViewController?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        Loading.showLoading(backgroundColor: .white)
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            if UserDefaultsManager.shared.isLogin() && !VersionService.shared.isOldVersion {
                checkLoginUser()
                
            } else {
                UserDefaultsManager.shared.removeAll()
                rootViewController = UINavigationController(rootViewController: SignViewController())
                configRootViewController(rootViewController ?? UIViewController())
                return
            }
        }
    }
    
    // 사용법 :
    // (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootView(UIViewController(), animated: true)
    /// 루트뷰 변경
    func changeRootView(_ viewController: UIViewController, animated: Bool) {
        guard let window = self.window else { return }
        
        if animated {
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromRight
            window.layer.add(transition, forKey: kCATransition)
        }
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        print("sceneDidDisconnect")
        CheckService.shared.updateOnline(userId: UserDefaultsManager.shared.getUserData().userId, isOnline: false) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                print("sceneDidDisconnect \(UserDefaultsManager.shared.getUserData().phoneNumber) 번호의 세션이 삭제되었습니다.")
            }
        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        print("sceneDidBecomeActive")
        NotificationService.shared.displayResetBadge()
        
        FirestoreService.shared.loadDocument(collectionId: .tokens, documentId: UserDefaultsManager.shared.getUserData().userId, dataType: Token.self) { result in
            
            switch result {
            case .success(let data):
                print("================= sceneDidBecomeActive 토큰 : \(String(describing: data))")
                if let data {
                    Messaging.messaging().token { [weak self] token, error in
                        guard let self else { return }
                        
                        if let error = error {
                            print("================= sceneDidBecomeActive 토큰 가져오기 실패 : \(error)")
                            return
                        }
                        
                        if let token {
                            if data.fcmToken == token {
                                equalTotoken()
                                
                            } else {
                                UserDefaultsManager.shared.removeAll()
                                changeRootView(UINavigationController(rootViewController: SignViewController(signType: .other)), animated: true)
                            }
                        } else {
                            print("================= sceneDidBecomeActive 토큰 없음")
                        }
                    }
                } else {
                    print("================= sceneDidBecomeActive 로그인한적없음")
                }
                
            case .failure(let err):
                print("================= sceneDidBecomeActive: \(err)")
            }
        }
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        CheckService.shared.updateOnline(userId: UserDefaultsManager.shared.getUserData().userId, isOnline: false) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                print("백그라운드로 이동하셨습니다.\(UserDefaultsManager.shared.getUserData().phoneNumber) 번호의 세션이 삭제되었습니다.")
            }
        }
    }
    
    private func checkLoginUser() {
        let user = UserDefaultsManager.shared.getUserData()
        
        CheckService.shared.checkStopUser(userNumber: user.phoneNumber) { [weak self] isStop, stop in
            guard let self else { return }
            if isStop {
                guard let stop else { return }
                
                let currentDate = Date()
                if let resumedDate = stop.endDate {
                    if currentDate > resumedDate {
                        FirestoreService.shared.saveDocument(collectionId: .users, documentId: stop.user.id, data: stop.user) { [weak self] result in
                            guard let self else { return }
                            
                            switch result {
                            case .success(let res):
                                if res {
                                    checkLoginUserFromOnline(userId: user.userId) { [weak self] result in
                                        guard let self else { return }
                                        if result {
                                            FirestoreService.shared.deleteDocument(collectionId: .stop, field: "phoneNumber", isEqualto: user.phoneNumber)
                                            configRootViewController(TabBarController())
                                        }
                                    }
                                }
                            case .failure(let err):
                                print("checkLoginUser : \(err)")
                            }
                        }
                        
                    } else {
                        UserDefaultsManager.shared.removeAll()
                        rootViewController = UINavigationController(rootViewController: SignViewController(signType: .stop(during: stop.during, endDate: stop.endDateString)))
                        configRootViewController(rootViewController ?? UIViewController())
                        return
                    }
                }
                
            } else {
                CheckService.shared.checkBlockUser(userNumber: user.phoneNumber) { [weak self] isBlock in
                    guard let self else { return }
                    if isBlock {
                        UserDefaultsManager.shared.removeAll()
                        rootViewController = UINavigationController(rootViewController: SignViewController(signType: .block))
                        configRootViewController(rootViewController ?? UIViewController())
                        return
                        
                    } else {
                        checkLoginUserFromOnline(userId: user.userId) { [weak self] result in
                            guard let self else { return }
                            if result {
                                configRootViewController(TabBarController())
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func checkLoginUserFromOnline(userId: String, completion: @escaping (Bool) -> ()) {
        CheckService.shared.checkOnline(userId: userId) { result in
            if result {
                if UserDefaultsManager.shared.isLogin() {
                    completion(true) // 자동로그인 상태에서 로그인이 되어있을 때
                    return
                }
            } else {
                CheckService.shared.updateOnline(userId: userId, isOnline: true) {
                    completion(true) // 자동로그인 상태에서 로그인 가능할때
                    return
                }
            }
        }
    }
    
    private func equalTotoken() {
        CheckService.shared.checkBlockUser(userNumber: UserDefaultsManager.shared.getUserData().phoneNumber) { [weak self] result in
            guard let self else { return }

            if result {
                UserDefaultsManager.shared.removeAll()
                changeRootView(UINavigationController(rootViewController: SignViewController(signType: .block)), animated: true)
                return
            }
        }

        CheckService.shared.checkStopUser(userNumber: UserDefaultsManager.shared.getUserData().phoneNumber) { [weak self] result, stop in
            guard let self else { return }

            if result, let stop {
                UserDefaultsManager.shared.removeAll()
                changeRootView(UINavigationController(rootViewController: SignViewController(signType: .stop(during: stop.during, endDate: stop.endDateString))), animated: true)
                return
            }
        }
        
        CheckService.shared.updateOnline(userId: UserDefaultsManager.shared.getUserData().userId, isOnline: true, completion: nil)
    }
    
    private func configRootViewController(_ viewController: UIViewController) {
        rootViewController = viewController
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        Loading.hideLoading()
    }
}
