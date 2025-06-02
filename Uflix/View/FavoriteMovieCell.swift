//
//  FavoriteMovieCell.swift
//  Uflix
//
//  Created by 정유진 on 5/22/25.
//

import UIKit
import SnapKit
import Kingfisher

class FavoriteMovieCell: UITableViewCell {
    static let identifier = "FavoriteMovieCell"
    
    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let overviewLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = UIColor.AppColor.background

        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 6
        
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = UIColor.AppColor.textPrimary
        titleLabel.numberOfLines = 1
        
        overviewLabel.font = .systemFont(ofSize: 13)
        overviewLabel.textColor = UIColor.AppColor.textSecondary
        overviewLabel.numberOfLines = 2
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, overviewLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(textStack)
        
        thumbnailImageView.snp.makeConstraints {
            $0.left.top.bottom.equalToSuperview().inset(12)
            $0.width.equalTo(80)
            $0.height.equalTo(100).priority(.high)
        }
        
        textStack.snp.makeConstraints {
            $0.left.equalTo(thumbnailImageView.snp.right).offset(12)
            $0.right.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
        }
    }
    
    func configure(movie: FavoriteMovie) {
        titleLabel.text = movie.title
        overviewLabel.text = movie.title
        
        if let path = movie.posterPath {
            let url = URL(string: "https://image.tmdb.org/t/p/w500\(path)")
            thumbnailImageView.kf.setImage(with: url)
        } else {
            thumbnailImageView.image = UIImage(systemName: "photo")
        }
    }
}
