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

class SearchViewController: UIViewController {
    private let viewModel = SearchViewModel()
    private let disposeBag = DisposeBag()
    
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let headerLabel = UILabel()
    private let clearButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: HistoryCell.identifier)
        
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
        // 헤더 뷰 자체 생성
        
    }
    
    private func bind() {
        // viewModel 바인딩
    }
}
