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
    
    struct Input {
        let editButtonTapped: Observable<Void>
        let itemSelected: Observable<FavoriteMovie>
    }
    
    struct Output {
        let movies: Driver<[FavoriteMovie]>
        let isEditing: Driver<Bool>
        let selectedIDs: Driver<Set<Int>>
    }
    
    let allMovies = BehaviorRelay<[FavoriteMovie]>(value: [])
    let isEditingRelay = BehaviorRelay<Bool>(value: false)
    let selectedIDsRelay = BehaviorRelay<Set<Int>>(value: [])
    
    private let disposeBag = DisposeBag()
    
    init() {
        fetchFavorites()
    }
    
    func transform(input: Input) -> Output {
        input.editButtonTapped
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                let newState = !self.isEditingRelay.value
                self.isEditingRelay.accept(newState)
                if !newState {
                    self.selectedIDsRelay.accept([])
                }
            }).disposed(by: disposeBag)
       
        input.itemSelected
            .subscribe(onNext: { [weak self] movie in
                guard let self = self else { return }
                if self.isEditingRelay.value {
                    var selected = self.selectedIDsRelay.value
                    let id = Int(movie.id)
                    if selected.contains(id) {
                        selected.remove(id)
                    } else {
                        selected.insert(id)
                    }
                    self.selectedIDsRelay.accept(selected)
                }
            }).disposed(by: disposeBag)
        
        return Output(
            movies: allMovies.asDriver(),
            isEditing: isEditingRelay.asDriver(),
            selectedIDs: selectedIDsRelay.asDriver()
        )
    }
    
    func fetchFavorites() {
        let favorites = CoreDataManager.shared.fetchFavorites()
        allMovies.accept(favorites)
    }
    
    func deleteFavorite(_ movie: FavoriteMovie) {
        CoreDataManager.shared.deleteFavorite(id: Int(movie.id))
        fetchFavorites() // 삭제 후 목록 다시 불러오기
    }
}
