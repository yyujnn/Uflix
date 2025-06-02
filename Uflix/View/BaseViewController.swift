//
//  BaseViewController.swift
//  Uflix
//
//  Created by 정유진 on 5/22/25.
//

import UIKit

class BaseViewController: UIViewController {
    
    /// 네비게이션 바를 숨길지 여부 - 자식 VC에서 필요 시 override
    var hidesNavigationBar: Bool { return false }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(hidesNavigationBar, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // 다음 화면으로 push될 때 뒤로가기 텍스트 제거
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground() // 투명 비활성화
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.AppColor.textPrimary]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance // 스크롤 시에도 동일하게 적용
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = UIColor.AppColor.textPrimary // back 버튼 등 tint 색상
    }
}
