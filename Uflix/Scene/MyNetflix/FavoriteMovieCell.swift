//
//  FavoriteMovieCell.swift
//  Uflix
//
//  Created by 정유진 on 5/22/25.
//

import UIKit
import SnapKit
import Kingfisher

class FavoriteMovieCell: UICollectionViewCell {
    static let identifier = "FavoriteMovieCell"
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let checkmark = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
    
    var isEditing: Bool = false {
        didSet {
            checkmark.isHidden = !isEditing
        }
    }
    
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
        imageView.backgroundColor = .gray
        
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = UIColor.AppColor.textSecondary
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        
        checkmark.tintColor = UIColor.AppColor.accentRed
        checkmark.isHidden = true

        [imageView, titleLabel].forEach {
            contentView.addSubview($0)
        }
        
        imageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(imageView.snp.width).multipliedBy(1.5) // 2:3 비율
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(4)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func configure(movie: FavoriteMovie) {
        titleLabel.text = movie.title
        checkmark.isHidden = !isEditing || !isSelected
        // 편집모드일 때, 선택 체크마크 표시
        
        if let path = movie.posterPath {
            let url = URL(string: "https://image.tmdb.org/t/p/w500\(path)")
            imageView.kf.setImage(with: url)
        } else {
            imageView.image = UIImage(systemName: "photo")
        }
    }
}
