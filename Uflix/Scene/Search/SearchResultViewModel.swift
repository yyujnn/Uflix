//
//  SearchResultViewModel.swift
//  Uflix
//
//  Created by 정유진 on 5/30/25.
//

import Foundation
import RxSwift
import RxCocoa

class SearchResultViewModel {
    let results = BehaviorRelay<[Movie]>(value: [])
    private let disposeBag = DisposeBag()
    
    let query: String
    
    init(query: String) {
        self.query = query
        fetchMovies(query: query)
    }
    
    private func fetchMovies(query: String) {
        MovieService.searchMovie(query: query)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movies in
                self?.results.accept(movies)
            }, onError: { error in
                print("검색 실패: \(error.localizedDescription)")
            }).disposed(by: disposeBag)
    }
}
