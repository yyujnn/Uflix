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
    private var output: SearchViewModel.Output?
    private let disposeBag = DisposeBag()
    private var cellBindingBag = DisposeBag()
    
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
        bindViewModel()
        bindUI()
    }
    
    private func bindViewModel() {
        let input = SearchViewModel.Input(
            query: searchBar.rx.text.orEmpty.asObservable(),
            clearAllTapped: clearButton.rx.tap.asObservable(),
            selectedKeyword: tableView.rx.modelSelected(String.self).asObservable())
        
        output = viewModel.transform(input: input)
        
        output?.selectedKeyword
            .drive(onNext: { [weak self] keyword in
                self?.navigateToResult(keyword: keyword)
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Bind
    private func bindUI() {
        tapGesture.rx.event
            .bind(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            }).disposed(by: disposeBag)
        
        searchBar.rx.text.orEmpty
            .distinctUntilChanged()
            .bind(onNext: { [weak self] text in
                let newMode: SearchMode = text.isEmpty ? .recent : .suggest
                self?.mode.accept(newMode)
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
        cellBindingBag = DisposeBag()
        
        switch mode {
        case .recent:
            output?.recentSearches
                .drive(tableView.rx.items(
                    cellIdentifier: HistoryCell.identifier,
                    cellType: HistoryCell.self
                )) { _, keyword, cell in
                    cell.configure(with: keyword)
                }.disposed(by: cellBindingBag)
        case .suggest:
            output?.suggestions
                .drive(tableView.rx.items(
                    cellIdentifier: SuggestCell.identifier,
                    cellType: SuggestCell.self
                )) { _, keyword, cell in
                    cell.configure(with: keyword)
                }.disposed(by: cellBindingBag)
        }
    }
    
    private func navigateToResult(keyword: String) {
        let resultVC = SearchResultViewController(keyword: keyword)
        navigationController?.pushViewController(resultVC, animated: true)
    }

    private func updateView(for mode: SearchMode) {
        tableView.tableHeaderView = (mode == .recent) ? headerView : nil
        tableView.reloadData()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.AppColor.background
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        searchBar.placeholder = "영화를 검색해보세요."
        searchBar.barStyle = .black
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = .white
        searchBar.searchTextField.textColor = .white
        searchBar.searchTextField.backgroundColor = .darkGray
        
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        tableView.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.identifier)
        tableView.register(SuggestCell.self, forCellReuseIdentifier: SuggestCell.identifier)
        
        [ searchBar, tableView ].forEach{ view.addSubview($0) }
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(-30)
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
        
        SearchHistoryManager.save(keyword)
        viewModel.refreshRecentSearches()
        navigateToResult(keyword: keyword)
    }
}
