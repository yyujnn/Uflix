//
//  SearchResultViewController.swift
//  Uflix
//
//  Created by 정유진 on 5/30/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class SearchResultViewController: UIViewController {
    // TODO: SearchBar
    private let viewModel: SearchResultViewModel
    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.isUserInteractionEnabled = false
        bar.searchBarStyle = .minimal
        bar.barStyle = .black
        bar.tintColor = .white
        bar.searchTextField.textColor = .white
        bar.searchTextField.backgroundColor = .darkGray
        return bar
    }()

    private let resultView = SearchResultView()
    private let disposeBag = DisposeBag()
    
    init(keyword: String) {
        self.viewModel = SearchResultViewModel(query: keyword)
        super.init(nibName: nil, bundle: nil)
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func setupNavigationBar() {
        searchBar.text = viewModel.query
        navigationItem.titleView = searchBar

        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.AppColor.background
        view.addSubview(resultView)
        
        resultView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func bind() {
        viewModel.results
            .bind(to: resultView.collectionView.rx.items(
                cellIdentifier: PosterCell.id,
                cellType: PosterCell.self
            )) {_, movie, cell in
                cell.configure(with: movie)
            }.disposed(by: disposeBag)
        
        resultView.collectionView.rx.modelSelected(Movie.self)
            .subscribe(onNext: { movie in
                let detailViewModel = DetailViewModel(movie: movie)
                let detailVC = DetailViewController(viewModel: detailViewModel)
                self.navigationController?.pushViewController(detailVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
