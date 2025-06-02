//
//  MyNetflixViewController.swift
//  Uflix
//
//  Created by 정유진 on 5/20/25.
//

import UIKit
import RxSwift
import RxCocoa

class MyNetflixViewController: BaseViewController {
    override var hidesNavigationBar: Bool { return true }
    
    private let viewModel: MyNetflixViewModel
    private let disposeBag = DisposeBag()
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        cv.register(FavoriteMovieCell.self, forCellWithReuseIdentifier: FavoriteMovieCell.identifier)
        cv.backgroundColor = UIColor.AppColor.background
        return cv
    }()

    
    init(viewModel: MyNetflixViewModel) {
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
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        viewModel.fetchFavorites()
    }

    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / 3),
            heightDimension: .estimated(180)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(180)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: 3
        )
        
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = .init(top: 10, leading: 10, bottom: 20, trailing: 10)

        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.AppColor.background
        
        collectionView.backgroundColor = UIColor.AppColor.background
        collectionView.register(FavoriteMovieCell.self, forCellWithReuseIdentifier: FavoriteMovieCell.identifier)
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
    }
    
    private func bind() {
        let input = MyNetflixViewModel.Input(
            editButtonTapped: .empty(),
            itemSelected: collectionView.rx.modelSelected(FavoriteMovie.self).asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.movies
            .drive(collectionView.rx.items(
                cellIdentifier: FavoriteMovieCell.identifier,
                cellType: FavoriteMovieCell.self
            )) { index, movie, cell in
                cell.configure(movie: movie)
            }.disposed(by: disposeBag)
        
        // 셀  클릭: 상세 페이지 이동
        collectionView.rx.modelSelected(FavoriteMovie.self)
            .subscribe(onNext: { [weak self] movie in
                let model = Movie(id: Int(movie.id), title: movie.title ?? "", posterPath: movie.posterPath, overview: movie.overview ?? "")
                let detailVM = DetailViewModel(movie: model)
                let detailVC = DetailViewController(viewModel: detailVM)
                self?.navigationController?.pushViewController(detailVC, animated: true)
            }).disposed(by: disposeBag)
    }
}
