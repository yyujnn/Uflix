//
//  SuggestCell.swift
//  Uflix
//
//  Created by 정유진 on 5/31/25.
//

import UIKit
import SnapKit

class SuggestCell: UITableViewCell {
    static let identifier = "SuggestCell"

    private let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.AppColor.background
        
        titleLabel.textColor = UIColor.AppColor.textSecondary
        titleLabel.font = .systemFont(ofSize: 14)
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
        }
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}
