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
    
    private let disposeBag = DisposeBag()
    
    /// View 가 구독할 Subject
    let popularMovieSubject = BehaviorSubject(value: [Movie]())
    let topRatedMovieSubject = BehaviorSubject(value: [Movie]())
    let upcomingMovieSubject = BehaviorSubject(value: [Movie]())
    
    
    init() {
        fetchPopularMovie()
        fetchTopRatedMovie()
        fetchUpcomingMovie()
    }
    
    /// Popular Movie 데이터를 불러온다.
    /// ViewModel 에서 수행해야할 비즈니스 로직.
    func fetchPopularMovie() {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=\(APIKeys.tmdb)") else {
            popularMovieSubject.onError(NetworkError.invalidUrl)
            return
        }
       
        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: { [weak self] (movieResponse: MovieResponse) in
                self?.popularMovieSubject.onNext(movieResponse.results)
            }, onFailure: { [weak self] error in
                self?.popularMovieSubject.onError(error)
            }).disposed(by: disposeBag)
    }
    
    func fetchTopRatedMovie() {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/top_rated?api_key=\(APIKeys.tmdb)") else {
            topRatedMovieSubject.onError(NetworkError.invalidUrl)
            return
        }
        
        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: { [weak self] (movieResponse: MovieResponse) in
                self?.topRatedMovieSubject.onNext(movieResponse.results)
            }, onFailure: { [weak self] error in
                self?.topRatedMovieSubject.onError(error)
            }).disposed(by: disposeBag)
    }
    
    func fetchUpcomingMovie() {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/upcoming?api_key=\(APIKeys.tmdb)") else {
            upcomingMovieSubject.onError(NetworkError.invalidUrl)
            return
        }
        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: { [weak self] (movieResponse: MovieResponse) in
                self?.upcomingMovieSubject.onNext(movieResponse.results)
            }, onFailure: { [weak self] error in
                self?.upcomingMovieSubject.onError(error)
            }).disposed(by: disposeBag)
    }
    
    /// 예고편 영상 key
    func fetchTrailerKey(movie: Movie) -> Single<String> {
        guard let movieId = movie.id else { return Single.error(NetworkError.dataFetchFail) }
        let urlString = "https://api.themoviedb.org/3/movie/\(movieId)/videos?api_key=\(APIKeys.tmdb)"
        guard let url = URL(string: urlString) else {
            return Single.error(NetworkError.invalidUrl)
        }
        
        /// --> flatMap? : Single의 String 타입으로 변환해줌 (싱글 타입 지정해주고 싶을 때 사용 가능하다 ⭐️)
        /// VideoResponse.results.first: results 중 첫번째 영상 선택
        /// key를 사용한 유튜브 영상 보기 위해 String Key 반환
        return NetworkManager.shared.fetch(url: url) // --> 리턴타입: Signle<VideoResponse>
            .flatMap { (VideoResponse: VideoResponse) -> Single<String> in
                if let trailer = VideoResponse.results.first(where: { $0.type == "Trailer" && $0.site
                    == "YouTube"}) {
                    guard let key = trailer.key else { return Single.error(NetworkError.dataFetchFail) }
                    return Single.just(key)
                } else {
                    return Single.error(NetworkError.dataFetchFail)
                }
            }
    }
    
}
