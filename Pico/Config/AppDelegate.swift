//
//  AppDelegate.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import KakaoSDKCommon
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        VersionService.shared.loadAppStoreVersion { latestVersion in
            guard let latestVersion else { return }
            
            let nowVersion = VersionService.shared.nowVersion()
            let compareResult = nowVersion.compare(latestVersion, options: .numeric)
            
            switch compareResult {
            case .orderedAscending:
                VersionService.shared.isOldVersion = true
            case .orderedDescending:
                VersionService.shared.isOldVersion = false
            case .orderedSame:
                VersionService.shared.isOldVersion = false
            }
        }
        
        FirebaseApp.configure()
        KakaoSDK.initSDK(appKey: Bundle.main.kakaoAppKey)
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
        
        if let userInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any] {
            if let aps = userInfo["aps"]  as? [String: Any], let alert = aps["alert"] as? [String: Any] {
                if alert["subtitle"] != nil {
                    moveChattingView()
                } else {
                    moveNotificationView()
                }
            }
        }
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        NotificationService.shared.displayResetBadge()
        completionHandler([.list, .banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let aps = userInfo["aps"]  as? [String: Any], let alert = aps["alert"] as? [String: Any] {
            if alert["subtitle"] != nil {
                moveChattingView()
            } else {
                moveNotificationView()
            }
        }
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let aps = userInfo["aps"] as? [String: Any], let badge = aps["badge"] as? Int {
            if #available(iOS 16.0, *) {
                UNUserNotificationCenter.current().setBadgeCount(badge)
            } else {
                UIApplication.shared.applicationIconBadgeNumber = badge
            }
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    private func moveNotificationView() {
        if UIApplication.shared.connectedScenes.first?.delegate is SceneDelegate {
            guard let rootViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else { return }
            let notificationViewController = NotificationViewController()
            if let tabBarController = rootViewController as? UITabBarController {
                if let selectedNavigationController = tabBarController.selectedViewController as? UINavigationController {
                    selectedNavigationController.pushViewController(notificationViewController, animated: true)
                }
            } else if rootViewController is UINavigationController {
                rootViewController.navigationController?.pushViewController(notificationViewController, animated: true)
            }
        }
    }
    
    private func moveChattingView() {
        if UIApplication.shared.connectedScenes.first?.delegate is SceneDelegate {
            guard let rootViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else { return }
            if let tabBarController = rootViewController as? UITabBarController {
                tabBarController.selectedIndex = 1
                if let navigationController = tabBarController.viewControllers?[1] as? UINavigationController {
                    navigationController.popToRootViewController(animated: true)
                }
            }
        }
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("FCM등록 토큰 : \(token)")
        let dataDict: [String: String] = ["token": token]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
}
