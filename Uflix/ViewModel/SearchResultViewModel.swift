//
//  SearchResultViewModel.swift
//  Uflix
//
//  Created by 정유진 on 5/30/25.
//

import Foundation
import RxSwift
import RxCocoa

enum TMDBEndpoint {
    static func searchMovie(query: String) -> URL? {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://api.themoviedb.org/3/search/movie?api_key=\(APIKeys.tmdb)&query=\(encoded)")
    }
}

class SearchResultViewModel {
    private let query: String
    let results = BehaviorRelay<[Movie]>(value: [])
    private let disposeBag = DisposeBag()
    
    init(query: String) {
        self.query = query
        fetchMovie()
    }
    
    func fetchMovie() {
        guard let url = TMDBEndpoint.searchMovie(query: query) else { return }
        
        NetworkManager.shared.fetch(url: url)
            .asObservable()
            .map { (response: MovieResponse) in response.results }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movies in
                self?.results.accept(movies)
            }, onError: { error in
                print("검색 실패: \(error.localizedDescription)")
            }).disposed(by: disposeBag)
    }
}
