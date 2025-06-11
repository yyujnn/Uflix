//
//  DetailViewModel.swift
//  Uflix
//
//  Created by 정유진 on 5/18/25.
//

import Foundation
import RxSwift

class DetailViewModel {
    struct Input {
        let toggleFavoriteTapped: Observable<Void>
    }
    
    struct Output {
        let movieDetail: Observable<Movie>
        let isFavorite: Observable<Bool>
        let trailerKey: Observable<String>
        let error: Observable<Error>
    }
    
    private let disposeBag = DisposeBag()
    private let movie: Movie
    
    let movieDetailSubject: BehaviorSubject<Movie>
    let trailerKeySubject = ReplaySubject<String>.create(bufferSize: 1)
    let errorSubject = PublishSubject<Error>()
    let isFavoriteSubject = BehaviorSubject<Bool>(value: false)
    
    
    init(movie: Movie) {
        self.movie = movie
        self.movieDetailSubject = BehaviorSubject(value: movie)
        checkFavoriteStatus()
        fetchTrailerKey()
    }

    func transform(input: Input) -> Output {
        input.toggleFavoriteTapped
            .withLatestFrom(isFavoriteSubject)
            .subscribe(onNext: { [weak self] current in
                self?.toggleFavorite(current)
            }).disposed(by: disposeBag)
        
        return Output(
            movieDetail: movieDetailSubject.asObservable(),
            isFavorite: isFavoriteSubject.asObservable(),
            trailerKey: trailerKeySubject.asObservable(),
            error: errorSubject.asObservable()
        )
    }
    
    func checkFavoriteStatus() {
        let current = CoreDataManager.shared.isFavorite(id: movie.id)
        isFavoriteSubject.onNext(current)
    }
    
    func toggleFavorite(_ current: Bool) {
        let id = movie.id
        if current {
            CoreDataManager.shared.deleteFavorite(id: id)
            isFavoriteSubject.onNext(false)
        } else {
            CoreDataManager.shared.saveFavorite(movie: movie)
            isFavoriteSubject.onNext(true)
        }
        
        let all = CoreDataManager.shared.fetchFavorites()
        print("✅ 저장된 찜 목록 개수: \(all.count)")
    }
    
    /// 예고편 영상 key
    func fetchTrailerKey() {
        let movieId = movie.id
        let urlString = "https://api.themoviedb.org/3/movie/\(movieId)/videos?api_key=\(APIKeys.tmdb)"
        guard let url = URL(string: urlString) else {
            errorSubject.onNext(NetworkError.invalidUrl)
            return
        }
        
        NetworkManager.shared.fetch(url: url) // --> 리턴타입: Signle<VideoResponse>
            .flatMap { (response: VideoResponse) -> Single<String> in
                if let trailer = response.results.first(where: { $0.type == "Trailer" && $0.site
                    == "YouTube"}),
                   let key = trailer.key {
                    print("✅ 예고편 찾음:", key)
                    return Single.just(key)
                } else {
                    print("❌ 예고편 없음")
                    return Single.error(NetworkError.dataFetchFail) }
            }
            .subscribe(onSuccess: { [weak self] key in
                self?.trailerKeySubject.onNext(key)
            }, onFailure: { [weak self] error in
                self?.trailerKeySubject.onError(error)
                self?.errorSubject.onNext(error)
            }).disposed(by: disposeBag)
    }
}
