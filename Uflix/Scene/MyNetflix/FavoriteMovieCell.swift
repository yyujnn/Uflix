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
    
    private let checkOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()

    private let checkIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        imageView.tintColor = .white
        imageView.isHidden = true
        return imageView
    }()
    
    override var isSelected: Bool {
        didSet {
            updateCheckUI()
        }
    }

    var isEditing: Bool = false {
        didSet {
            updateCheckUI()
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

        [imageView, titleLabel, checkOverlayView ].forEach {
            contentView.addSubview($0)
        }
        
        imageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(imageView.snp.width).multipliedBy(1.5)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(4)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        checkOverlayView.snp.makeConstraints {
            $0.edges.equalTo(imageView) // 포스터 위에 오버레이
        }

        checkOverlayView.addSubview(checkIcon)
        checkIcon.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(6)
            $0.width.height.equalTo(24)
        }
    }
    
    func configure(movie: FavoriteMovie, isEditing: Bool, isSelected: Bool) {
        titleLabel.text = movie.title
        self.isEditing = isEditing
        self.isSelected = isSelected
        
        if let path = movie.posterPath {
            let url = URL(string: "https://image.tmdb.org/t/p/w500\(path)")
            imageView.kf.setImage(with: url)
        } else {
            imageView.image = UIImage(systemName: "photo")
        }
        
        updateCheckUI()
    }

    
    private func updateCheckUI() {
        let show = isEditing && isSelected
        checkOverlayView.isHidden = !show
        checkIcon.isHidden = !show
    }

}
