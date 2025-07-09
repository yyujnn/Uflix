//
//  DetailViewModel.swift
//  Uflix
//
//  Created by 정유진 on 5/18/25.
//

import Foundation
import RxSwift
import RxCocoa

class DetailViewModel {
    struct Input {
        let toggleFavoriteTapped: Observable<Void>
    }
    
    struct Output {
        let movieDetail: Observable<Movie>
        let isFavorite: Observable<Bool>
        let trailerKey: Observable<String>
        let likeButtonState: Observable<LikeButtonState>
        let error: Observable<Error>
        let recommendedMovies: Observable<[Movie]>
    }
    
    private let disposeBag = DisposeBag()
    let movie: Movie
    
    let movieDetailSubject: BehaviorSubject<Movie>
    let trailerKeySubject = ReplaySubject<String>.create(bufferSize: 1)
    let errorSubject = PublishSubject<Error>()
    let isFavoriteSubject = BehaviorSubject<Bool>(value: false)
    let recommendedMoviesRelay = BehaviorRelay<[Movie]>(value: [])
    
    
    init(movie: Movie) {
        self.movie = movie
        self.movieDetailSubject = BehaviorSubject(value: movie)
        checkFavoriteStatus()
        fetchTrailerKey()
        fetchRecommendations()
    }

    func transform(input: Input) -> Output {
        input.toggleFavoriteTapped
            .withLatestFrom(isFavoriteSubject)
            .subscribe(onNext: { [weak self] current in
                self?.toggleFavorite(current)
            }).disposed(by: disposeBag)
        
        let likeButtonState = isFavoriteSubject
            .map { $0 ? LikeButtonState.liked : LikeButtonState.unliked }
            .asObservable()
        
        return Output(
            movieDetail: movieDetailSubject.asObservable(),
            isFavorite: isFavoriteSubject.asObservable(),
            trailerKey: trailerKeySubject.asObservable(),
            likeButtonState: likeButtonState,
            error: errorSubject.asObservable(),
            recommendedMovies: recommendedMoviesRelay.asObservable()
        )
    }
    
    func checkFavoriteStatus() {
        let current = CoreDataManager.shared.isFavorite(id: movie.id)
        if let previous = try? isFavoriteSubject.value(), previous == current { return }
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
    
    func fetchRecommendations() {
        MovieService.fetchRecommendations(for: movie.id)
            .subscribe(onNext: { [weak self] movies in
                print("✅ 추천 영화 목록:")
                movies.forEach { movie in
                    print("\(movie.title ?? "제목 없음")")
                }
                self?.recommendedMoviesRelay.accept(Array(movies.prefix(10)))
            }, onError:  { [weak self] error in
                print("❌ 추천 영화 가져오기 실패:", error.localizedDescription)
                self?.errorSubject.onNext(error)
            }).disposed(by: disposeBag)
    }
}
enum LikeButtonState {
    case liked
    case unliked
    
    var isLiked: Bool {
        return self == .liked
    }
    
    var imageName: String {
        return isLiked ? "checkmark" : "plus"
    }
}
