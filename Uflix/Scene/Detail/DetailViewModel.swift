//
//  DetailViewModel.swift
//  Uflix
//
//  Created by 정유진 on 5/18/25.
//

import Foundation
import RxSwift

class DetailViewModel {
    
    private let disposeBag = DisposeBag()
    private let movie: Movie

    let movieDetail: BehaviorSubject<Movie>
    let trailerKey = ReplaySubject<String>.create(bufferSize: 1)
    let error = PublishSubject<Error>()
    let isFavorite = BehaviorSubject<Bool>(value: false)
    
    init(movie: Movie) {
        self.movie = movie
        self.movieDetail = BehaviorSubject(value: movie)
        checkFavoriteStatus()
        fetchTrailerKey()
    }
    
    func checkFavoriteStatus() {
        let current = CoreDataManager.shared.isFavorite(id: movie.id)
        isFavorite.onNext(current)
    }
    
    func toggleFavorite() {
        let id = movie.id
        let current = (try? isFavorite.value()) ?? false
        
        if current {
            CoreDataManager.shared.deleteFavorite(id: id)
            isFavorite.onNext(false)
            // onNext(...) → "이벤트 발생"
        } else {
            CoreDataManager.shared.saveFavorite(movie: movie)
            isFavorite.onNext(true)
        }
        
        // 확인 log
        let all = CoreDataManager.shared.fetchFavorites()
        print("✅ 저장된 찜 목록 개수: \(all.count)")
        all.forEach{ print("찜 영화: \($0.title ?? "제목 없음")")}
    }
    
    /// 예고편 영상 key
    func fetchTrailerKey() {
        let movieId = movie.id
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
                    print("✅ 예고편 찾음:", key)
                    return Single.just(key)
                } else {
                    print("❌ 예고편 없음")
                    return Single.error(NetworkError.dataFetchFail) }
            }
            .subscribe(onSuccess: { [weak self] key in
                self?.trailerKey.onNext(key)
            }, onFailure: { [weak self] error in
                self?.error.onNext(error)
            }).disposed(by: disposeBag)
    }
}
