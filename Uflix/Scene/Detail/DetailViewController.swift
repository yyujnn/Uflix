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
    
    private var isExpanded = false
    private var didCheckOverviewLines = false
    private var fallbackImageURL: URL?

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let videoContainerView = UIView()
    private let playerView = YTPlayerView()
    private let fallbackImageView = UIImageView()
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let noVideoLabel = UILabel()
    
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let overviewLabel = UILabel()
    private let moreButton = UIButton(type: .system)
    private let overviewContainer = UIView()
    
    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "plus")
        config.title = "찜"
        config.baseForegroundColor = UIColor.AppColor.textSecondary
        config.imagePadding = 8
        config.imagePlacement = .top
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attr in
            var attr = attr
            attr.font = .systemFont(ofSize: 12)
            return attr
        }
        button.configuration = config
        return button
    }()

    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "square.and.arrow.up")
        config.title = "공유"
        config.baseForegroundColor = UIColor.AppColor.textSecondary
        config.imagePadding = 8
        config.imagePlacement = .top
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attr in
            var attr = attr
            attr.font = .systemFont(ofSize: 12)
            return attr
        }
        button.configuration = config
        return button
    }()

    private let buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        guard !isExpanded else {
            moreButton.isHidden = false
           return
        }
        
        moreButton.isHidden = !overviewLabel.isTruncated
    }
    
    @objc private func toggleOverview() {
        isExpanded.toggle()
        overviewLabel.numberOfLines = isExpanded ? 0 : 3
        moreButton.setTitle(isExpanded ? "간략히" : "더보기", for: .normal)
    }
    
    private func updateLikeButton(imageName: String) {
        UIView.animate(withDuration: 0.15, animations: {
            self.likeButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            var config = self.likeButton.configuration
            config?.image = UIImage(
                systemName: imageName,
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            )
            self.likeButton.configuration = config

            UIView.animate(withDuration: 0.15) {
                self.likeButton.transform = .identity
            }
        }
    }
    
    private func bind() {
        let input = DetailViewModel.Input(
            toggleFavoriteTapped: likeButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.movieDetail
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] in self?.configure(movie: $0) })
            .disposed(by: disposeBag)
        
        output.likeButtonState
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] state in
                self?.updateLikeButton(imageName: state.imageName)
            }).disposed(by: disposeBag)
        
        output.trailerKey
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] key in
                self?.fallbackImageView.isHidden = true
                self?.noVideoLabel.isHidden = true
                self?.playerView.load(withVideoId: key)
            }, onError: { [weak self] error in
                guard let self else { return }
                self.playerView.isHidden = true
                self.fallbackImageView.isHidden = false
                self.noVideoLabel.isHidden = false
                if let url = self.fallbackImageURL {
                    self.fallbackImageView.kf.setImage(with: url) { _ in
                        self.fallbackImageView.alpha = 0.6
                    }
                }
            }).disposed(by: disposeBag)
        
        output.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { error in
                print("❗️Error: \(error.localizedDescription)")
            }).disposed(by: disposeBag)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.AppColor.background
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
        }
        
        setupVideoSection()
        setupStackView()
        setupButtons()
    }
    
    private func setupVideoSection() {
        contentView.addSubview(videoContainerView)
        
        videoContainerView.clipsToBounds = true
        videoContainerView.layer.cornerRadius = 8
        videoContainerView.snp.makeConstraints {
            $0.top.equalTo(contentView.safeAreaLayoutGuide.snp.top)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(220)
        }
        
        videoContainerView.addSubview(playerView)
        playerView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        videoContainerView.addSubview(fallbackImageView)
        fallbackImageView.contentMode = .scaleAspectFill
        fallbackImageView.clipsToBounds = true
        fallbackImageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        videoContainerView.addSubview(noVideoLabel)
        noVideoLabel.text = "예고편을 불러올 수 없습니다"
        noVideoLabel.textColor = .white
        noVideoLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        noVideoLabel.textAlignment = .center
        noVideoLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.left.right.equalToSuperview().inset(16)
        }
    }
    
    private func setupStackView() {
        contentView.addSubview(stackView)
        
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.snp.makeConstraints {
            $0.top.equalTo(videoContainerView.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(20)
        }
        
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor.AppColor.textPrimary
        
        stackView.addArrangedSubview(titleLabel)
    }
    
    private func setupButtons() {
        overviewLabel.font = .systemFont(ofSize: 16)
        overviewLabel.textColor = UIColor.AppColor.textSecondary
        overviewLabel.numberOfLines = 3
        
        moreButton.setTitle("더보기", for: .normal)
        moreButton.setTitleColor(UIColor.AppColor.textDisabled, for: .normal)
        moreButton.titleLabel?.font = .systemFont(ofSize: 14)
        moreButton.contentHorizontalAlignment = .right
        moreButton.addTarget(self, action: #selector(toggleOverview), for: .touchUpInside)
        
        overviewContainer.addSubview(overviewLabel)
        overviewContainer.addSubview(moreButton)
        
        overviewLabel.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
        }
        
        moreButton.snp.makeConstraints {
            $0.top.equalTo(overviewLabel.snp.bottom).offset(4)
            $0.left.right.bottom.equalToSuperview()
        }
        
        stackView.addArrangedSubview(overviewContainer)
        
        contentView.addSubview(buttonStackView)
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(16)
            $0.left.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        likeButton.snp.makeConstraints {
            $0.width.height.equalTo(60)
        }
        

        buttonStackView.addArrangedSubview(likeButton)
        buttonStackView.addArrangedSubview(shareButton)
    }

    private func configure(movie: Movie) {
        titleLabel.text = movie.title
        overviewLabel.text = movie.overview
        
        if let posterPath = movie.posterPath {
            fallbackImageURL = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
        }
    }
}

extension UILabel {
    var isTruncated: Bool {
        guard let text = self.text else { return false }
        let size = CGSize(width: bounds.width, height: .greatestFiniteMagnitude)
        let attributes: [NSAttributedString.Key: Any] = [.font: font as Any]
        let rect = text.boundingRect(with: size, options: [.usesLineFragmentOrigin], attributes: attributes, context: nil)
        return rect.height > bounds.height
    }
}
