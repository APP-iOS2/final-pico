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
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        print("SceneDelegate UserDefaultsManager ===== \(UserDefaultsManager.shared.isLogin())")
        print("SceneDelegate VersionService.shared.isOldVersion ===== \(VersionService.shared.isOldVersion)")
        if UserDefaultsManager.shared.isLogin() && !VersionService.shared.isOldVersion {
            checkSuccessLogin()
            
        } else {
            UserDefaultsManager.shared.removeAll()
            rootViewController = UINavigationController(rootViewController: SignViewController())
        }
        
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
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
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        
        CheckService.shared.updateOnline(userId: UserDefaultsManager.shared.getUserData().userId, isOnline: false) {
            sleep(3)
            print("sceneDidDisconnect \(UserDefaultsManager.shared.getUserData().phoneNumber) 번호의 세션이 삭제되었습니다.")
        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        NotificationService.shared.displayResetBadge()
        
        CheckService.shared.checkOnline(userId: UserDefaultsManager.shared.getUserData().userId) { result in
            if result {
                print("================= sceneDidBecomeActive")
                UserDefaultsManager.shared.removeAll()
                let signViewController = UINavigationController(rootViewController: SignViewController())
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootView(signViewController, animated: true)
                
            } else {
                DispatchQueue.main.async {
                    Messaging.messaging().token { token, error in
                        if let error = error {
                            print("================= sceneDidBecomeActive 토큰 가져오기 실패 : \(error)")
                            return
                        } else if let token {
                            FirestoreService.shared.loadDocument(collectionId: .tokens, documentId: UserDefaultsManager.shared.getUserData().userId, dataType: Token.self) { [weak self] result in
                                guard let self else { return }
                                
                                switch result {
                                case .success(let data):
                                    if let data {
                                        if data.fcmToken == token {
                                            CheckService.shared.updateOnline(userId: UserDefaultsManager.shared.getUserData().userId, isOnline: true, completion: nil)
                                        } else {
                                            UserDefaultsManager.shared.removeAll()
                                            let signViewController = UINavigationController(rootViewController: SignViewController())
                                            if rootViewController != signViewController {
                                                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootView(signViewController, animated: true)
                                            }
                                        }
                                    }
                                    
                                case .failure(let err):
                                    print("================= sceneDidBecomeActive: \(err)")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        CheckService.shared.updateOnline(userId: UserDefaultsManager.shared.getUserData().userId, isOnline: false) {
            sleep(3)
            print("백그라운드로 이동하셨습니다.\(UserDefaultsManager.shared.getUserData().phoneNumber) 번호의 세션이 삭제되었습니다.")
        }
    }
    
    private func checkSuccessLogin() {
        let user = UserDefaultsManager.shared.getUserData()
        
        DispatchQueue.main.async {
            CheckService.shared.checkStopUser(userNumber: user.phoneNumber) { [weak self] isStop, stop in
                guard let self else { return }
                if isStop {
                    guard let stop else { return }
                    
                    let currentDate = Date()
                    let stopDate = Date(timeIntervalSince1970: stop.createdDate)
                    let stopDuring = stop.during
                    let stopUser = stop.user
                    
                    if let resumedDate = Calendar.current.date(byAdding: .day, value: stopDuring, to: stopDate) {
                        Loading.hideLoading()
                        if currentDate > resumedDate {
                            FirestoreService.shared.saveDocument(collectionId: .users, documentId: stopUser.id, data: stopUser) { _ in
                                FirestoreService.shared.deleteDocument(collectionId: .stop, field: "phoneNumber", isEqualto: user.phoneNumber)
                            }
                            
                        } else {
                            rootViewController = UINavigationController(rootViewController: SignViewController())
                        }
                    }
                    
                } else {
                    CheckService.shared.checkBlockUser(userNumber: user.phoneNumber) { [weak self] isBlock in
                        guard let self else { return }
                        if isBlock {
                            rootViewController = UINavigationController(rootViewController: SignViewController())
                            
                        } else {
                            CheckService.shared.checkOnline(userId: user.userId) { [weak self] result in
                                guard let self else { return }
                                if result {
                                    Loading.hideLoading()
                                    if UserDefaultsManager.shared.isLogin() {
                                        // 자동로그인 상태에서 로그인이 되어있을 때
                                        rootViewController = UINavigationController(rootViewController: TabBarController())
                                    }
                                } else {
                                    CheckService.shared.updateOnline(userId: user.userId, isOnline: true) { [weak self] in
                                        guard let self else { return }
                                        // 자동로그인 상태에서 로그인 가능할때
                                        rootViewController = UINavigationController(rootViewController: TabBarController())
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
