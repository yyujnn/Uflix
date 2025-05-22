//
//  MyNetflixViewController.swift
//  Uflix
//
//  Created by 정유진 on 5/20/25.
//

import UIKit
import RxSwift
import RxCocoa

class MyNetflixViewController: UIViewController {
    private let viewModel: MyNetflixViewModel
    private let disposeBag = DisposeBag()
    
    private let tableView = UITableView()
    
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
    }

    private func setupUI() {
        view.backgroundColor = .white
        
        tableView.register(FavoriteMovieCell.self, forCellReuseIdentifier: FavoriteMovieCell.identifier)
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func bind() {
        // 데이터 바인딩
        viewModel.favoriteMovies
            .bind(to: tableView.rx.items(cellIdentifier: FavoriteMovieCell.identifier, cellType: FavoriteMovieCell.self)) { index, movie, cell in
                cell.configure(movie: movie)
            }.disposed(by: disposeBag)
        
        // 셀  클릭: 상세 페이지 이동
        tableView.rx.modelSelected(FavoriteMovie.self)
            .subscribe(onNext: { [weak self] movie in
                let model = Movie(id: Int(movie.id), title: movie.title ?? "", posterPath: movie.posterPath, overview: movie.overview ?? "")
                let detailVM = DetailViewModel(movie: model)
                let detailVC = DetailViewController(viewModel: detailVM)
                self?.navigationController?.pushViewController(detailVC, animated: true)
            }).disposed(by: disposeBag)
        
        // 스와이프 삭제
        tableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                let movie = self.viewModel.favoriteMovies.value[indexPath.row]
                self.viewModel.deleteFavorite(movie)
            }).disposed(by: disposeBag)
    }
}
