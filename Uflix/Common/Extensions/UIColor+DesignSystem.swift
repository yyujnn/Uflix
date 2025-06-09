//
//  UIColor+DesignSystem.swift
//  Uflix
//
//  Created by 정유진 on 6/2/25.
//

import UIKit

extension UIColor {
    enum AppColor {
        static let accentRed = UIColor(named: "appAccentRed") ?? .red
        static let background = UIColor(named: "appBackground") ?? .systemBackground
        static let textPrimary = UIColor(named: "textPrimary") ?? .white
        static let textSecondary = UIColor(named: "textSecondary") ?? .secondaryLabel
        static let textDisabled = UIColor(named: "textDisabled") ?? .tertiaryLabel
    }
}
