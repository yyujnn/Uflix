//
//  DetailViewController.swift
//  Uflix
//
//  Created by 정유진 on 5/18/25.
//

import UIKit
import SnapKit
import YouTubeiOSPlayerHelper
import RxSwift

class DetailViewController: UIViewController {
    private let viewModel: DetailViewModel
    
    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let overviewLabel = UILabel()
    private let playerView = YTPlayerView()
    private let likeButton = UIButton(type: .system)
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureData()
        bind()
    }
    
    private func bind() {
        
    }
    
    private func configureUI() {
        view.backgroundColor = .black
        
        [
            posterImageView,
            titleLabel,
            overviewLabel,
            playerView,
            likeButton
        ].forEach { view.addSubview($0) }
        
        posterImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(150)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(posterImageView.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(20)
        }
        
        overviewLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(20)
        }
        
        playerView.snp.makeConstraints {
            $0.top.equalTo(overviewLabel.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(200)
        }
        
        likeButton.snp.makeConstraints {
            $0.top.equalTo(playerView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        titleLabel.font = .boldSystemFont(ofSize: 20)
        overviewLabel.numberOfLines = 0
        likeButton.setTitle("❤️ 찜하기", for: .normal)
    }
    
    private func configureData() {
        let movie = viewModel.movie
        titleLabel.text = movie.title
        overviewLabel.text = movie.overview
        /// TODO: SDWebImage
    }
}
