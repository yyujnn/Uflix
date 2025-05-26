//
//  HistoryCell.swift
//  Uflix
//
//  Created by 정유진 on 5/23/25.
//

import UIKit
import SnapKit
import Kingfisher

class HistoryCell: UITableViewCell {
    static let identifier = "HistoryCell"

    private let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .black
        
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 14)
        
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
        }
    }
    
    func configure(with text: String) {
        titleLabel.text = text
    }
}
