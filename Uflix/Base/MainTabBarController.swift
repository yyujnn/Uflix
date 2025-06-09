//
//  MainTabBarController.swift
//  Uflix
//
//  Created by 정유진 on 5/22/25.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeVC = MainViewController()
        let searchVC = SearchViewController()
        let myVC = MyNetflixViewController(viewModel: MyNetflixViewModel())
        
        let homeNav = BaseNavigationController(rootViewController: homeVC)
        let searchNav = BaseNavigationController(rootViewController: searchVC)
        let myNav = BaseNavigationController(rootViewController: myVC)
        
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        let homeImage = UIImage(systemName: "house", withConfiguration: iconConfig)
        let searchImage = UIImage(systemName: "magnifyingglass", withConfiguration: iconConfig)
        let myImage = UIImage(systemName: "heart", withConfiguration: iconConfig)
        
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: homeImage, tag: 0)
        searchVC.tabBarItem = UITabBarItem(title: "Search", image: searchImage, tag: 1)
        myVC.tabBarItem = UITabBarItem(title: "My", image: myImage, tag: 2)
        
        viewControllers = [homeNav, searchNav, myNav]
        
        // 탭바 스타일
        tabBar.barTintColor = UIColor.AppColor.background
        tabBar.tintColor = UIColor.AppColor.textPrimary
        tabBar.unselectedItemTintColor = UIColor.AppColor.textDisabled
        tabBar.isTranslucent = false
    }
}

