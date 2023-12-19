//
//  SceneDelegate.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        if VersionService.shared.isOldVersion {
            UserDefaultsManager.shared.removeAll()
        }
        
        if UserDefaultsManager.shared.isLogin() {
            let checkService = CheckService()
            let user: User = User.tempUser
            let currentUser = UserDefaultsManager.shared.getUserData()
            
            checkService.checkStopUser(userNumber: currentUser.phoneNumber) { [weak self] isStop, stop in
                guard let self = self else { return }
                guard isStop else { return }
                let currentDate = Date()
                let stopDate = Date(timeIntervalSince1970: stop.createdDate)
                let stopDuring = stop.during
                let stopUser = stop.user
                
                if let resumedDate = Calendar.current.date(byAdding: .day, value: stopDuring, to: stopDate) {
                    if currentDate > resumedDate {
                        Loading.hideLoading()
                        FirestoreService.shared.saveDocument(collectionId: .users, documentId: stopUser.id, data: stopUser) { _ in }
                        
                        FirestoreService.shared.removeDocument(collectionId: .stop, field: "phoneNumber", isEqualto: currentUser.phoneNumber)
                    } else {
                        Loading.hideLoading()
                        UserDefaultsManager.shared.removeAll()
                        let rootViewController = UINavigationController(rootViewController: SignViewController())
                        self.window?.rootViewController = rootViewController
                    }
                }
            }
            
            checkService.checkBlockUser(userNumber: currentUser.phoneNumber) { isBlock in
                if isBlock {
                    UserDefaultsManager.shared.removeAll()
                    let rootViewController = UINavigationController(rootViewController: SignViewController())
                    self.window?.rootViewController = rootViewController
                }
            }
            
            checkService.checkUserId(userId: currentUser.userId) { isUser in
                if isUser {
                    FirestoreService.shared.saveDocument(collectionId: .session, documentId: currentUser.phoneNumber, data: user) { _ in }
                    let rootViewController = TabBarController()
                    self.window?.rootViewController = rootViewController
                } else {
                    let rootViewController = UINavigationController(rootViewController: SignViewController())
                    self.window?.rootViewController = rootViewController
                }
            }
        } else {
            let rootViewController = UINavigationController(rootViewController: SignViewController())
            window?.rootViewController = rootViewController
        }
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
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        NotificationService.shared.displayResetBadge()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        let userDefaultsManager = UserDefaultsManager()
        guard userDefaultsManager.isLogin() else { return }
        FirestoreService.shared.saveDocument(collectionId: .session, documentId: userDefaultsManager.getUserData().phoneNumber, data: User.tempUser) { _ in }
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        let userDefaultsManager = UserDefaultsManager()
        guard userDefaultsManager.isLogin() else { return }
        let checkService = CheckService()
        checkService.disConnectSession() { }
        print("끊킴")
    }
}
