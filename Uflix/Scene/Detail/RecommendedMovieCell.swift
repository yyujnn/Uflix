//
//  RecommendedMovieCell.swift
//  Uflix
//
//  Created by 정유진 on 7/4/25.
//

import UIKit
import SnapKit
import Kingfisher

class RecommendedMovieCell: UICollectionViewCell {
    static let identifier = "RecommendedMovieCell"
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
            super.init(frame: frame)
            setupUI()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    private func setupUI() {
        contentView.backgroundColor = UIColor.AppColor.background
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .darkGray
        
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = UIColor.AppColor.textSecondary
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        imageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(imageView.snp.width).multipliedBy(1.5)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(4)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        if let path = movie.posterPath {
            let url = URL(string: "https://image.tmdb.org/t/p/w500\(path)")
            imageView.kf.setImage(with: url)
        } else {
            imageView.image = UIImage(systemName: "photo")
        }
    }
}
