//
//  MyNetflixViewModel.swift
//  Uflix
//
//  Created by 정유진 on 5/20/25.
//

import Foundation
import RxSwift
import RxCocoa

class MyNetflixViewModel {
    private let disposeBag = DisposeBag()
       
       // CoreData에서 가져온 찜한 영화 목록
       let favoriteMovies = BehaviorRelay<[FavoriteMovie]>(value: [])
       
       init() {
           fetchFavorites()
       }
       
       func fetchFavorites() {
           let favorites = CoreDataManager.shared.fetchFavorites()
           favoriteMovies.accept(favorites)
       }
       
       func deleteFavorite(_ movie: FavoriteMovie) {
           CoreDataManager.shared.deleteFavorite(id: Int(movie.id))
           fetchFavorites() // 삭제 후 목록 다시 불러오기
       }
}
