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
    private let titleLabel = UILabel()
    private let overviewLabel = UILabel()
    private let playerView = YTPlayerView()
    private let likeButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)
    private let buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        return stack
    }()
    
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
        self.navigationController?.setNavigationBarHidden(false, animated: false)
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
                let title = isFav ?  "❤️ 찜 취소" : "🤍 찜 하기"
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
        view.backgroundColor = UIColor.AppColor.background
        
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
            $0.top.equalTo(contentView.safeAreaLayoutGuide.snp.top)
            $0.left.right.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        playerView.snp.makeConstraints { $0.height.equalTo(200) }
        
        titleLabel.textColor = UIColor.AppColor.textPrimary
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.numberOfLines = 0
        
        overviewLabel.textColor = UIColor.AppColor.textSecondary
        overviewLabel.font = .systemFont(ofSize: 16)
        overviewLabel.numberOfLines = 0
        
        likeButton.setTitleColor(.white, for: .normal)
        likeButton.backgroundColor = UIColor.AppColor.textDisabled
        likeButton.layer.cornerRadius = 8
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        likeButton.snp.makeConstraints { $0.height.equalTo(44) }

        shareButton.setTitle("📤 공유", for: .normal)
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.backgroundColor = UIColor.AppColor.textDisabled
        shareButton.layer.cornerRadius = 8
        shareButton.snp.makeConstraints { $0.height.equalTo(44) }
        
        [playerView, titleLabel, overviewLabel, buttonStackView].forEach {
            stackView.addArrangedSubview($0)
        }
        
        buttonStackView.addArrangedSubview(likeButton)
        buttonStackView.addArrangedSubview(shareButton)
    }

    private func configure(movie: Movie) {
        titleLabel.text = movie.title
        overviewLabel.text = movie.overview
    }
}
