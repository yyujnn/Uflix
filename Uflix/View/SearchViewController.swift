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
    private let dynamicDisposeBag = DisposeBag() // tableView 바인딩 분리
    
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let headerLabel = UILabel()
    private let clearButton = UIButton(type: .system)
    private let headerView = UIView()
    private let tapGesture = UITapGestureRecognizer()
    
    private let mode = BehaviorRelay<SearchMode>(value: .recent)
    enum SearchMode {
        case recent
        case suggest
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        setupUI()
        bind()
    }
    
    private func bind() {
        tapGesture.rx.event
            .bind(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            }).disposed(by: disposeBag)
        
        searchBar.rx.text.orEmpty
            .distinctUntilChanged()
            .bind(onNext: { [weak self] text in
                let newMode: SearchMode = text.isEmpty ? .recent : .suggest
                self?.mode.accept(newMode)
                self?.viewModel.query.accept(text)
            }).disposed(by: disposeBag)
        
        clearButton.rx.tap
            .bind(to: viewModel.clearAllTapped)
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(String.self)
            .subscribe(onNext: { [weak self] keyword in
                self?.viewModel.selectedKeyword.accept(keyword)
                self?.navigateToResult(keyword: keyword)
            }).disposed(by: disposeBag)
        
        mode
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] newMode in
                self?.updateView(for: newMode)
                self?.bindTableView(for: newMode)
            }).disposed(by: disposeBag)
    }
    
    private func bindTableView(for mode: SearchMode) {
        tableView.dataSource = nil
        tableView.delegate = nil
        
        let bindingBag = DisposeBag()

        switch mode {
        case .recent:
            viewModel.recentSearches
                .bind(to: tableView.rx.items(cellIdentifier: HistoryCell.identifier, cellType: HistoryCell.self)) { _, keyword, cell in
                    cell.configure(with: keyword)
                }.disposed(by: disposeBag)
        case .suggest:
            viewModel.suggestions
                .bind(to: tableView.rx.items(cellIdentifier: SuggestCell.identifier, cellType: SuggestCell.self)) { _, keyword, cell in
                    cell.configure(with: keyword)
                }.disposed(by: disposeBag)
        }
        
        // DisposeBag 업데이트
    }
    
    private func navigateToResult(keyword: String) {
        let resultVC = SearchResultViewController(keyword: keyword)
        navigationController?.pushViewController(resultVC, animated: true)
    }

    private func updateView(for mode: SearchMode) {
        switch mode {
        case .recent:
            headerView.isHidden = false
        case .suggest:
            headerView.isHidden = true
        }
        tableView.reloadData()
    }

    private func setupUI() {
        view.backgroundColor = .black
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        searchBar.placeholder = "영화를 검색해보세요."
        searchBar.barStyle = .black
        searchBar.tintColor = .white
        searchBar.searchTextField.textColor = .white
        searchBar.searchTextField.backgroundColor = .darkGray
        
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        tableView.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.identifier)
        tableView.register(SuggestCell.self, forCellReuseIdentifier: SuggestCell.identifier)
        
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

        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        tableView.tableHeaderView = headerView
    }
}
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let keyword = searchBar.text ?? ""
        guard !keyword.isEmpty else { return }
        navigateToResult(keyword: keyword)
    }
}
