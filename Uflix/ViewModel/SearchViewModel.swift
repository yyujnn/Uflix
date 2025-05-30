//
//  SearchViewModel.swift
//  Uflix
//
//  Created by 정유진 on 5/23/25.
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

class SearchViewModel {
    // Input
    // PublishRelay --> 초기값 x, 이벤트 발생(버튼/탭 등)
    let clearAllTapped = PublishRelay<Void>()
    let selectedKeyword = PublishRelay<String>()
    let query = PublishRelay<String>()
    
    // Output
    // BehaviorRelay --> 초기값, 최신값 o, 즉시 전달 (상태 보관)
    var recentSearches = BehaviorRelay<[String]>(value: SearchHistoryManager.load())
    
    let results = BehaviorRelay<[Movie]>(value: [])
    let error = PublishRelay<Error>()
    
    private let disposeBag = DisposeBag()
    
    init() {
        // qeury 바인딩
        bindInput()
    }
    
    // API 호출 로직
    func searchMovie(query: String) -> Observable<[Movie]>{
        guard let url = TMDBEndpoint.searchMovie(query: query) else {
            return .error(NetworkError.invalidUrl)
        }
        
        return NetworkManager.shared.fetch(url: url)
            .asObservable()
            .map{ (response: MovieResponse) in response.results }
    }
    
    private func bindInput() {
        // 검색어 입력  → TMDB 검색 API 호출
        query.debounce(.microseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest{ [weak self] keyword -> Observable<[Movie]> in
                guard let self = self else { return .empty() }
                return self.searchMovie(query: keyword)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movies in
                self?.results.accept(movies)
            }, onError: { [weak self] error in
                self?.error.accept(error)
            }).disposed(by: disposeBag)
            
        // 전체 삭제
        clearAllTapped
            .subscribe(onNext: {
                // 이벤트가 들어왔을 때 실행할 코드
                SearchHistoryManager.clear()
                self.recentSearches.accept([])
            }).disposed(by: disposeBag)
    
        // 최근 검색어 선택: 히스토리 갱신
        selectedKeyword
            .subscribe(onNext: { keyword in
                SearchHistoryManager.save(keyword)
                self.recentSearches.accept(SearchHistoryManager.load())
            }).disposed(by: disposeBag)
    }
}
