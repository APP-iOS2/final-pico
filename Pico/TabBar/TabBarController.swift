//
//  TabBarController.swift
//  Pico
//
//  Created by 최하늘 on 2023/09/25.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        UITabBar.appearance().backgroundColor = UIColor.white
        UITabBar.appearance().tintColor = UIColor.picoBlue
    }
    
    private func configureTabBar() {
        let homeViewController = UINavigationController(rootViewController: HomeViewController())
        let mailViewController = UINavigationController(rootViewController: MailViewController())
        let likeViewController = UINavigationController(rootViewController: LikeViewController())
        let entViewController = UINavigationController(rootViewController: EntViewController())
        let mypageViewController = UINavigationController(rootViewController: MypageViewController())
        
        homeViewController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
        mailViewController.tabBarItem = UITabBarItem(title: "Mail", image: UIImage(systemName: "envelope.fill"), tag: 1)
        likeViewController.tabBarItem = UITabBarItem(title: "Like", image: UIImage(systemName: "heart.fill"), tag: 2)
        entViewController.tabBarItem = UITabBarItem(title: "Ent", image: UIImage(systemName: "gamecontroller.fill"), tag: 3)
        mypageViewController.tabBarItem = UITabBarItem(title: "MyPage", image: UIImage(systemName: "person.fill"), tag: 4)
        
        homeViewController.navigationBar.prefersLargeTitles = false
        mailViewController.navigationBar.prefersLargeTitles = false
        likeViewController.navigationBar.prefersLargeTitles = false
        entViewController.navigationBar.prefersLargeTitles = false
        mypageViewController.navigationBar.prefersLargeTitles = false
        
        self.viewControllers = [homeViewController, mailViewController, likeViewController, entViewController, mypageViewController]
        delegate = self
    }
}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MyTransition(viewControllers: tabBarController.viewControllers)
    }
}
