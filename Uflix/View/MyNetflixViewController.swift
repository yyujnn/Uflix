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
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "My Netflix"
        
        tableView.register(FavoriteMovieCell.self, forCellReuseIdentifier: FavoriteMovieCell.identifier)
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func bind() {
        viewModel.favoriteMovies
            .bind(to: tableView.rx.items(cellIdentifier: FavoriteMovieCell.identifier, cellType: FavoriteMovieCell.self)) { index, movie, cell in
                cell.configure(movie: movie)
            }.disposed(by: disposeBag)
    }
}
