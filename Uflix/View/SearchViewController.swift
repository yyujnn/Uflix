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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    private func bind() {
        // viewModel 바인딩
        viewModel.recentSearches
            .bind(to: tableView.rx.items(
                cellIdentifier: HistoryCell.identifier, cellType: HistoryCell.self
            )) {_, keyword, cell in
                cell.configure(with: keyword)
            }.disposed(by: disposeBag)
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        searchBar.placeholder = "영화를 검색해보세요."
        searchBar.barStyle = .black
        searchBar.tintColor = .white
        searchBar.searchTextField.textColor = .white
        searchBar.searchTextField.backgroundColor = .darkGray
        
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        tableView.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.identifier)
        
        [ searchBar, tableView ].forEach{ view.addSubview($0) }
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
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
