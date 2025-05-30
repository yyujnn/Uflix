//
//  SearchViewController.swift
//  Uflix
//
//  Created by 정유진 on 5/23/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class SearchViewController: BaseViewController {
    override var hidesNavigationBar: Bool { return true }
    
    private let viewModel = SearchViewModel()
    private let disposeBag = DisposeBag()
    
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let headerLabel = UILabel()
    private let clearButton = UIButton(type: .system)
    private let headerView = UIView()
    private let resultView = SearchResultView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    private func bind() {
        // 검색어 입력 → query로 전달
        searchBar.rx.text.orEmpty
            .skip(1)
            .distinctUntilChanged()
            .bind(to: viewModel.query)
            .disposed(by: disposeBag)
        
        // 검색어 입력 여부에 따른 화면 전환
        searchBar.rx.text.orEmpty
            .bind(onNext: { [weak self] text in
                guard let self = self else { return }
                let isEmpty = text.isEmpty
                self.tableView.isHidden = !isEmpty
                self.resultView.isHidden = isEmpty
            }).disposed(by: disposeBag)
        
        // [Input] '전체 삭제' 버튼 탭 → clearAllTapped
        clearButton.rx.tap
            .bind(to: viewModel.clearAllTapped)
            .disposed(by: disposeBag)
        
        // [Input] 검색 기록 선택 → selectedKeyword
        tableView.rx.modelSelected(String.self)
            .bind(to: viewModel.selectedKeyword)
            .disposed(by: disposeBag)
        
        // [Output] 최근 검색어 → tableView 렌더링
        viewModel.recentSearches
            .bind(to: tableView.rx.items(
                cellIdentifier: HistoryCell.identifier,
                cellType: HistoryCell.self
            )) { _, keyword, cell in
                cell.configure(with: keyword)
            }.disposed(by: disposeBag)
        
        // [Output] 검색 결과 → collectionView 렌더링
        viewModel.results
            .bind(to: resultView.collectionView.rx.items(
                cellIdentifier: PosterCell.id,
                cellType: PosterCell.self
            )) { _, movie, cell in
                cell.configure(with: movie)
            }.disposed(by: disposeBag)
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        resultView.isHidden = true
        
        searchBar.placeholder = "영화를 검색해보세요."
        searchBar.barStyle = .black
        searchBar.tintColor = .white
        searchBar.searchTextField.textColor = .white
        searchBar.searchTextField.backgroundColor = .darkGray
        
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        tableView.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.identifier)
        
        [ searchBar, tableView, resultView ].forEach{ view.addSubview($0) }
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        resultView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        setupTableHeader()
    }
    
    private func setupTableHeader() {
        headerView.backgroundColor = .black
        
        headerLabel.text = "최근 검색어"
        headerLabel.textColor = .white
        headerLabel.font = .boldSystemFont(ofSize: 16)
        
        clearButton.setTitle("전체 삭제", for: .normal)
        clearButton.setTitleColor(.gray, for: .normal)
        clearButton.titleLabel?.font = .systemFont(ofSize: 14)
        
        [headerLabel, clearButton].forEach { headerView.addSubview($0) }
        
        headerLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        clearButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }

        
        // 임시 높이 설정 (실제는 viewDidLayoutSubviews에서 재계산됨)
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        tableView.tableHeaderView = headerView
    }
}
