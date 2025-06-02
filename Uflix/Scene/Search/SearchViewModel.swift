//
//  SearchViewModel.swift
//  Uflix
//
//  Created by 정유진 on 5/23/25.
//

import Foundation
import RxSwift
import RxCocoa

class SearchViewModel {
    // MARK: - Input
    struct Input {
        let query: Observable<String>
        let clearAllTapped: Observable<Void>
        let selectedKeyword: Observable<String>
    }
    
    // MARK: - Output
    struct Output {
        let recentSearches: Driver<[String]>
        let suggestions: Driver<[String]>
        let selectedKeyword: Driver<String>
        let error: Driver<Error>
    }
    
    // MARK: - Private
    private let recentSearchesRelay = BehaviorRelay<[String]>(value: SearchHistoryManager.load())
    private let suggestionsRelay = BehaviorRelay<[String]>(value: [])
    private let errorRelay = PublishRelay<Error>()
    private let disposeBag = DisposeBag()
    
    // MARK: - Transform
    func transform(input: Input) -> Output {
        let selectedKeywordDriver = input.selectedKeyword
            .do(onNext: { keyword in
                SearchHistoryManager.save(keyword)
                self.recentSearchesRelay.accept(SearchHistoryManager.load())
            })
            .asDriver(onErrorDriveWith: .empty())
        
        input.query
            .debounce(.microseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest{ keyword in
                MovieService.searchMovie(query: keyword)
                    .map { $0.compactMap { $0.title } }
                    .catchAndReturn([])
            }
            .bind(to: suggestionsRelay)
            .disposed(by: disposeBag)
        
        input.clearAllTapped
            .subscribe(onNext: { [weak self] in
                SearchHistoryManager.clear()
                self?.recentSearchesRelay.accept([])
            }).disposed(by: disposeBag)
        
        return Output(
            recentSearches: recentSearchesRelay.asDriver(onErrorJustReturn: []),
            suggestions: suggestionsRelay.asDriver(onErrorJustReturn: []),
            selectedKeyword: selectedKeywordDriver,
            error: errorRelay.asDriver(onErrorDriveWith: .empty())
        )
    }
    
    func refreshRecentSearches() {
        recentSearchesRelay.accept(SearchHistoryManager.load())
    }
}
