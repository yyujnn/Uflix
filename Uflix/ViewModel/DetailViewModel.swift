//
//  DetailViewModel.swift
//  Uflix
//
//  Created by 정유진 on 5/18/25.
//

import Foundation
import RxSwift

final class DetailViewModel {
    
    private let disposeBag = DisposeBag()
    
    // input
    private let movie: Movie
    
    // output
    let movieDetail: BehaviorSubject<Movie>
    let trailerKey = PublishSubject<String>()
    let error = PublishSubject<Error>()
    
    init(movie: Movie) {
        self.movie = movie
        self.movieDetail = BehaviorSubject(value: movie)
        fetchTrailerKey()
    }
    
    /// 예고편 영상 key
    func fetchTrailerKey() {
        guard let movieId = movie.id else {
            error.onNext(NetworkError.dataFetchFail)
            return
        }
        
        let urlString = "https://api.themoviedb.org/3/movie/\(movieId)/videos?api_key=\(APIKeys.tmdb)"
        guard let url = URL(string: urlString) else {
            error.onNext(NetworkError.invalidUrl)
            return
        }
        
        NetworkManager.shared.fetch(url: url) // --> 리턴타입: Signle<VideoResponse>
            .flatMap { (response: VideoResponse) -> Single<String> in
                if let trailer = response.results.first(where: { $0.type == "Trailer" && $0.site
                    == "YouTube"}),
                   let key = trailer.key {
                    return Single.just(key)
                } else {
                    return Single.error(NetworkError.dataFetchFail) }
            }
            .subscribe(onSuccess: { [weak self] key in
                self?.trailerKey.onNext(key)
            }, onFailure: { [weak self] error in
                self?.error.onNext(error)
            }).disposed(by: disposeBag)
    }
}
