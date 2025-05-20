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
import Kingfisher

class DetailViewController: UIViewController {
    private let viewModel: DetailViewModel
    private let disposeBag = DisposeBag()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
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
        setupUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.checkFavoriteStatus()
    }

    @objc private func didTapLike() {
        print("🟢 찜 버튼 눌림")
        viewModel.toggleFavorite()
    }
    
    private func bind() {
        viewModel.movieDetail
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movie in
                self?.configure(movie: movie)
            }).disposed(by: disposeBag)
        
        viewModel.isFavorite
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isFav in
                // 여기 콜백은 언제든 값이 emit 되면 실행
                // subscribe(...) → "이벤트 받기"
                let title = isFav ?  "❤️ 찜 취소" : "🤍 찜하기"
                self?.likeButton.setTitle(title, for: .normal)
            }).disposed(by: disposeBag)
        
        viewModel.trailerKey
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] key in
                self?.playerView.load(withVideoId: key)
            }).disposed(by: disposeBag)
        
        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { error in
                print("error: \(error.localizedDescription)")
            }).disposed(by: disposeBag)
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // 스크롤뷰 설정
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
        }
        
        contentView.addSubview(stackView)
        
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        
        stackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(20)
            $0.left.right.equalToSuperview().inset(20)
        }
        
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.numberOfLines = 0
        
        overviewLabel.textColor = .lightGray
        overviewLabel.font = .systemFont(ofSize: 16)
        overviewLabel.numberOfLines = 0

        posterImageView.contentMode = .scaleAspectFit
        posterImageView.layer.cornerRadius = 8
        posterImageView.clipsToBounds = true
        
        likeButton.setTitle("❤️ 찜하기", for: .normal)
        likeButton.setTitleColor(.white, for: .normal)
        likeButton.backgroundColor = .darkGray
        likeButton.layer.cornerRadius = 8
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        likeButton.snp.makeConstraints { $0.height.equalTo(44) }
        
        // stackView에 추가
        [posterImageView, titleLabel, overviewLabel, playerView, likeButton].forEach {
            stackView.addArrangedSubview($0)
        }
        
        // playerView 고정 높이
        playerView.snp.makeConstraints { $0.height.equalTo(200) }
    }

    
    private func configure(movie: Movie) {
        titleLabel.text = movie.title
        overviewLabel.text = movie.overview
        
        if let posterPath = movie.posterPath {
            let url = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
            posterImageView.kf.setImage(with: url)
        }
    }
}
