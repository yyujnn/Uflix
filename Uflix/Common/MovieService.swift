//
//  MovieSercice.swift
//  Uflix
//
//  Created by 정유진 on 5/31/25.
//

import Foundation
import RxSwift

enum TMDBEndpoint {
    static func searchMovie(query: String) -> URL? {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://api.themoviedb.org/3/search/movie?api_key=\(APIKeys.tmdb)&query=\(encoded)")
    }
}

class MovieService {
    static func searchMovie(query: String) -> Observable<[Movie]> {
        
        guard let url = TMDBEndpoint.searchMovie(query: query) else {
            return .error(NetworkError.invalidUrl)
        }
        
        return NetworkManager.shared.fetch(url: url)
            .asObservable()
            .map{ (response: MovieResponse) in response.results }
    }
}
