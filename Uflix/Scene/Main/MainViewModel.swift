//
//  MainViewModel.swift
//  Uflix
//
//  Created by 정유진 on 5/13/25.
//

import Foundation
import RxSwift

enum APIKeys {
    static let tmdb: String = {
        guard let key = Bundle.main.infoDictionary?["TMDB_API_KEY"] as? String else {
            fatalError("API 키가 없음")
        }
        return key
    }()
}

class MainViewModel {
    struct Input {
        let fetchTrigger: Observable<Void>
    }
    
    struct Output {
        let popularMovies: Observable<[Movie]>
        let topRatedMovies: Observable<[Movie]>
        let upcomingMovies: Observable<[Movie]>
    }
    
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let popular = input.fetchTrigger
            .flatMapLatest { _ in self.fetchPopularMovie() }
            .share() // 중복 호출 방지
        
        let topRated = input.fetchTrigger
            .flatMapLatest { _ in self.fetchTopRatedMovie() }
            .share()
        
        let upcoming = input.fetchTrigger
            .flatMapLatest { _ in self.fetchUpcomingMovie() }
            .share()
        
        return Output(
            popularMovies: popular,
            topRatedMovies: topRated,
            upcomingMovies: upcoming
        )
    }
    
    private func fetchPopularMovie() -> Observable<[Movie]> {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=\(APIKeys.tmdb)") else {
            return .error(NetworkError.invalidUrl)
        }
        
        return NetworkManager.shared.fetch(url: url)
            .map { (response: MovieResponse) in response.results }
            .asObservable()
    }
    
    private func fetchTopRatedMovie() -> Observable<[Movie]> {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/top_rated?api_key=\(APIKeys.tmdb)") else {
            return .error(NetworkError.invalidUrl)
        }
        
        return NetworkManager.shared.fetch(url: url)
            .map { (response: MovieResponse) in response.results }
            .asObservable()
    }
    
    private func fetchUpcomingMovie() -> Observable<[Movie]> {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/upcoming?api_key=\(APIKeys.tmdb)") else {
            return .error(NetworkError.invalidUrl)
        }
        
        return NetworkManager.shared.fetch(url: url)
            .map { (response: MovieResponse) in response.results }
            .asObservable()
    }
}
