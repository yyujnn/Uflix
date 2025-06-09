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

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let playerView = YTPlayerView()
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
//        stack.spacing = 8
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

    @objc private func didTapLike() {
        viewModel.toggleFavorite()
    }

    @objc private func toggleOverview() {
        isExpanded.toggle()
        overviewLabel.numberOfLines = isExpanded ? 0 : 3
        moreButton.setTitle(isExpanded ? "간략히" : "더보기", for: .normal)
    }
    
    private func updateLikeButton(isFavorite: Bool) {
        UIView.animate(withDuration: 0.15, animations: {
            self.likeButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            var config = self.likeButton.configuration
            config?.image = UIImage(
                systemName: isFavorite ? "checkmark" : "plus",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            )
            self.likeButton.configuration = config

            UIView.animate(withDuration: 0.15) {
                self.likeButton.transform = .identity
            }
        }
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
                self?.updateLikeButton(isFavorite: isFav)
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

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
        }
        
        contentView.addSubview(stackView)
        contentView.addSubview(buttonStackView)
        
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.snp.makeConstraints {
            $0.top.equalTo(contentView.safeAreaLayoutGuide.snp.top)
            $0.left.right.equalToSuperview().inset(20)
        }
        
        playerView.snp.makeConstraints { $0.height.equalTo(200) }
        
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor.AppColor.textPrimary

        overviewLabel.font = .systemFont(ofSize: 16)
        overviewLabel.textColor = UIColor.AppColor.textSecondary
        overviewLabel.numberOfLines = 3

        moreButton.setTitle("더보기", for: .normal)
        moreButton.setTitleColor( UIColor.AppColor.textDisabled, for: .normal)
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
        
        [playerView, titleLabel, overviewContainer].forEach {
            stackView.addArrangedSubview($0)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(16)
            $0.left.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        likeButton.snp.makeConstraints {
            $0.width.height.equalTo(60)
        }
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)

        buttonStackView.addArrangedSubview(likeButton)
        buttonStackView.addArrangedSubview(shareButton)
    }

    private func configure(movie: Movie) {
        titleLabel.text = movie.title
        overviewLabel.text = movie.overview
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
