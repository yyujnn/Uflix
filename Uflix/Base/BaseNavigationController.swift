//
//  BaseNavigationController.swift
//  Uflix
//
//  Created by 정유진 on 6/9/25.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
    }

    private func configureAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
       
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.clear]
        
        let backImage = UIImage(systemName: "chevron.backward")?.withRenderingMode(.alwaysTemplate)
        appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
        
        navigationBar.tintColor = UIColor.AppColor.textPrimary
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
    }
}

