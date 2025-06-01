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
    let clearAllTapped = PublishRelay<Void>()
    let selectedKeyword = PublishRelay<String>()
    let query = PublishRelay<String>()
    
    var recentSearches = BehaviorRelay<[String]>(value: SearchHistoryManager.load())
    let suggestions = BehaviorRelay<[String]>(value: [])
    let error = PublishRelay<Error>()
    
    private let disposeBag = DisposeBag()
    
    init() {
        bindInput()
    }
    
    private func bindInput() {
        query
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest { keyword in
                MovieService.searchMovie(query: keyword)
                    .map { movies in
                        movies.compactMap { $0.title }
                    }
                    .catchAndReturn([])
            }
            .observe(on: MainScheduler.instance)
            .bind(to: suggestions)
            .disposed(by: disposeBag)
    
        clearAllTapped
            .subscribe(onNext: {
                SearchHistoryManager.clear()
                self.recentSearches.accept([])
            }).disposed(by: disposeBag)
    
        selectedKeyword
            .subscribe(onNext: { keyword in
                SearchHistoryManager.save(keyword)
                self.recentSearches.accept(SearchHistoryManager.load())
            }).disposed(by: disposeBag)
    }
}
