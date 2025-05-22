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
        let myVC = MyNetflixViewController(viewModel: MyNetflixViewModel())
        
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        let homeImage = UIImage(systemName: "house", withConfiguration: iconConfig)
        let myImage = UIImage(systemName: "heart", withConfiguration: iconConfig)
        
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: homeImage, tag: 0)
        myVC.tabBarItem = UITabBarItem(title: "My", image: myImage, tag: 1)
        
        // 탭바 스타일
        tabBar.barTintColor = .black
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = .lightGray
        tabBar.isTranslucent = false
        
        /// TODO: SearchVC 준비
        let homeNav = UINavigationController(rootViewController: homeVC)
        let myNav = UINavigationController(rootViewController: myVC)
        
        viewControllers = [homeNav, myNav]
    }
}

