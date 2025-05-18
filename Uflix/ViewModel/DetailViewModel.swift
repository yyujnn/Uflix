//
//  DetailViewModel.swift
//  Uflix
//
//  Created by 정유진 on 5/18/25.
//

import Foundation

final class DetailViewModel {
    let movie: Movie
    
    init(movie: Movie) {
        self.movie = movie
    }
    
    func fetchYoutubeVideoID(completion: @escaping (String?) -> Void) {
        // TMDB + YouTube 연동 로직
        // 예고편 video key 받아오기
    }
    
}
